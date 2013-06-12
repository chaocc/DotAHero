//
//  DhAesEncryptionContext.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsDhAesEncryptionContext.h"
#import "EsEngine.h"
#import "EsApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "DLOG.h"

@implementation EsDhAesEncryptionContext

- (id) init {
	DLOG();
	if (self = [super init]) {
		mp_init(&dhBase_);
		mp_init(&dhPrime_);
		mp_init(&dhSecret_);
		mp_init(&dhSharedSecret_);
	}
	return self;
}

- (void) setEnabled:(BOOL) enabled engine:(EsEngine*) engine connection:(EsConnection*) con {
	DLOG();
	if (enabled) {
		if (mp_cmp_d(&dhBase_, 0) == MP_EQ) {
			EsDHInitiateKeyExchangeRequest* r = [[EsDHInitiateKeyExchangeRequest alloc] init];
			[engine sendMessage:r onConnection:con];
		}
		else {
			EsEncryptionStateChangeEvent* r = [[EsEncryptionStateChangeEvent alloc] init];
			r.encryptionOn = true;
			[engine sendMessage:r onConnection:con];
			 
			outputEnabled_ = true;
		}
	}
	else {
		EsEncryptionStateChangeEvent* r = [[EsEncryptionStateChangeEvent alloc] init];
		r.encryptionOn = false;
		[engine sendMessage:r onConnection:con];
		 
		outputEnabled_ = true;
	}
}

- (void) handleIncomingMessage:(EsMessage*) message engine:(EsEngine*) engine connection:(EsConnection*) con {
	if ([message isKindOfClass:[EsDHPublicNumbersResponse class]]) {
		EsDHPublicNumbersResponse* e = (EsDHPublicNumbersResponse*) message;
		mp_read_radix(&dhBase_, [e.baseNumber cStringUsingEncoding:NSASCIIStringEncoding], 10);
		mp_read_radix(&dhPrime_, [e.primeNumber cStringUsingEncoding:NSASCIIStringEncoding], 10);
		// TODO this is calculating way wrong, seems to make huge numbers, revisit
		//mp_rand(&dhSecret_, (EsDhAesEncryptionContext_KEY_SIZE / 4));
		mp_rand(&dhSecret_, 10);
		mp_int gAmodP;
		mp_init(&gAmodP);
		mp_exptmod(&dhBase_, &dhSecret_, &dhPrime_, &gAmodP);
		
		DLOG(@"dhBase %@", [self stringFromMpInt:&dhBase_ radix:10]);
		DLOG(@"dhPrime %@", [self stringFromMpInt:&dhPrime_ radix:10]);
		DLOG(@"dhSecret %@", [self stringFromMpInt:&dhSecret_ radix:10]);
		DLOG(@"gAmodP %@", [self stringFromMpInt:&gAmodP radix:10]);
		
		EsDHSharedModulusRequest* r = [[EsDHSharedModulusRequest alloc] init];
		r.number = [self stringFromMpInt:&gAmodP radix:10];
		mp_clear(&gAmodP);
		[engine sendMessage:r onConnection:con];
	}
	else if ([message isKindOfClass:[EsDHSharedModulusResponse class]]) {
		EsDHSharedModulusResponse* e = (EsDHSharedModulusResponse*) message;
		mp_int gBmodP;
		mp_init(&gBmodP);
		mp_read_radix(&gBmodP, [e.number cStringUsingEncoding:NSASCIIStringEncoding], 10);
		mp_exptmod(&gBmodP, &dhSecret_, &dhPrime_, &dhSharedSecret_);
		mp_clear(&gBmodP);
		
		DLOG(@"dhSharedSecret %@", [self stringFromMpInt:&dhSharedSecret_ radix:10]);
		
		
		if (inputCipher_ == NULL) {
			[self prepareCiphers];
		}
		
		EsEncryptionStateChangeEvent* r = [[EsEncryptionStateChangeEvent alloc] init];
		r.encryptionOn = true;
		[engine sendMessage:r onConnection:con];
		
		outputEnabled_ = true;
	}
	else if ([message isKindOfClass:[EsEncryptionStateChangeEvent class]]) {
		EsEncryptionStateChangeEvent* e = (EsEncryptionStateChangeEvent*) message;
		if (e.encryptionOn) {
			if (outputEnabled_) {
				inputEnabled_ = true;
			}
			else {
				DLOG("Out of order encryption enable message from server.");
			}
		}
		else {
			if (inputEnabled_) {
				inputEnabled_ = false;
			}
			else {
				DLOG("Out of order encryption disable message from server.");
			}
		}
		
	}
}

- (void) handleOutgoingMessage:(EsMessage*) message engine:(EsEngine*) engine connection:(EsConnection*) con {
	DLOG();
}

// CCrypto does not offer CFB8 as an encryption mode so the two functions
// below implement the mode as part of the crypting.

- (void) encryptOutgoingMessage:(NSMutableData*) b {
	DLOG();
	
	if (!outputEnabled_) {
		return;
	}
	
	NSMutableData* cfbBlock = [NSMutableData dataWithLength:kCCBlockSizeAES128];
	unsigned char* bBytes = (unsigned char*) [b mutableBytes];
	unsigned char* cfbBlockBytes = (unsigned char*) [cfbBlock mutableBytes];
	unsigned char* outputIvBytes = (unsigned char*) [outputIv_ mutableBytes];
	size_t cfbBlockBytesOut;
	for (NSUInteger i = 0; i < [b length]; i++) {
		CCCryptorUpdate(outputCipher_, outputIvBytes, kCCBlockSizeAES128, cfbBlockBytes, kCCBlockSizeAES128, &cfbBlockBytesOut);
		CCCryptorFinal(outputCipher_, cfbBlockBytes, kCCBlockSizeAES128, &cfbBlockBytesOut);
		CCCryptorReset(outputCipher_, NULL);
		bBytes[i] ^= cfbBlockBytes[0];
		memcpy(outputIvBytes, outputIvBytes + 1, kCCBlockSizeAES128 - 1);
		outputIvBytes[kCCBlockSizeAES128 - 1] = bBytes[i];
	}
}
	
- (void) decryptIncomingMessage:(NSMutableData*) b {
	DLOG();
	
	if (!inputEnabled_) {
		return;
	}
	
	NSMutableData* cfbBlock = [NSMutableData dataWithLength:kCCBlockSizeAES128];
	unsigned char* bBytes = (unsigned char*) [b mutableBytes];
	unsigned char* cfbBlockBytes = (unsigned char*) [cfbBlock mutableBytes];
	unsigned char* inputIvBytes = (unsigned char*) [inputIv_ mutableBytes];
	size_t cfbBlockBytesOut;
	for (NSUInteger i = 0; i < [b length]; i++) {
		unsigned char bi = bBytes[i];
		CCCryptorUpdate(inputCipher_, inputIvBytes, kCCBlockSizeAES128, cfbBlockBytes, kCCBlockSizeAES128, &cfbBlockBytesOut);
		CCCryptorFinal(inputCipher_, cfbBlockBytes, kCCBlockSizeAES128, &cfbBlockBytesOut);
		CCCryptorReset(inputCipher_, NULL);
		bBytes[i] ^= cfbBlockBytes[0];
		memcpy(inputIvBytes, inputIvBytes + 1, kCCBlockSizeAES128 - 1);
		inputIvBytes[kCCBlockSizeAES128 - 1] = bi;
	}
}

- (BOOL) enabled {
	return inputEnabled_ && outputEnabled_;
}

- (void) prepareCiphers {
	DLOG();
	
	// To generate the two keys and two IVs we need we use 512 bits of the shared secret
	NSString* sharedSecretHex = [self stringFromMpInt:&dhSharedSecret_ radix:16];
	sharedSecretHex = [sharedSecretHex lowercaseString];
	
	NSString* outputKeyHex = [sharedSecretHex substringWithRange:NSMakeRange(0, 32)];
	NSString* outputIvHex = [sharedSecretHex substringWithRange:NSMakeRange(32, 32)];
	NSString* inputKeyHex = [sharedSecretHex substringWithRange:NSMakeRange(64, 32)];
	NSString* inputIvHex = [sharedSecretHex substringWithRange:NSMakeRange(96, 32)];
	
	DLOG(@"sharedSecretHex: %@", sharedSecretHex);
	DLOG(@"outputKeyHex: %@", outputKeyHex);
	DLOG(@"outputIvHex: %@", outputIvHex);
	DLOG(@"inputKeyHex: %@", inputKeyHex);
	DLOG(@"inputIvHex: %@", inputIvHex);
	
	NSData* inputSk = [self md5HashFromString:inputKeyHex];
	inputIv_ = [self md5HashFromString:inputIvHex];
	NSData* outputSk = [self md5HashFromString:outputKeyHex];
	outputIv_ = [self md5HashFromString:outputIvHex];
	
	DLOG(@"outputKeyBytes: %@", [EsObject hexDumpForData:outputSk]);
	DLOG(@"outputIvBytes: %@", [EsObject hexDumpForData:outputIv_]);
	DLOG(@"inputKeyBytes: %@", [EsObject hexDumpForData:inputSk]);
	DLOG(@"inputIvBytes: %@", [EsObject hexDumpForData:inputIv_]);
	
	
	CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, 0, [outputSk bytes], kCCKeySizeAES128, NULL, &outputCipher_);
	CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, 0, [inputSk bytes], kCCKeySizeAES128, NULL, &inputCipher_);
}
		   
- (NSMutableData*) md5HashFromString:(NSString*) s {
	const char* bytes = [s UTF8String];
	unsigned char hash[CC_MD5_DIGEST_LENGTH];
	CC_MD5_CTX ctx;
	CC_MD5_Init(&ctx);
	CC_MD5_Update(&ctx, bytes, strlen(bytes));
	CC_MD5_Final(hash, &ctx);
	NSMutableData* data = [NSMutableData dataWithBytes:hash length:CC_MD5_DIGEST_LENGTH];
	return data;
}

- (NSString*) stringFromMpInt:(mp_int*) mp radix:(int) radix {
	int length;
	mp_radix_size(mp, radix, &length);
	// add room for the NULL terminator
	length++;
	char* s = (char*) malloc(length);
	mp_toradix_n(mp, s, radix, length);
	NSString* ret = [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
	free(s);
	return ret;
}
@end

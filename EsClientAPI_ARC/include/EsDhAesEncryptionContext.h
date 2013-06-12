//
//  DhAesEncryptionContext.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tommath.h"
#import <CommonCrypto/CommonCryptor.h>

@class EsEngine;
@class EsConnection;
@class EsMessage;

#define EsDhAesEncryptionContext_KEY_SIZE 1024

@interface EsDhAesEncryptionContext : NSObject {
	@private	
	mp_int dhBase_;
	mp_int dhPrime_;
	mp_int dhSecret_;
	mp_int dhSharedSecret_;
	
	CCCryptorRef inputCipher_;
	CCCryptorRef outputCipher_;
	
	BOOL inputEnabled_;
	BOOL outputEnabled_;
	
	NSMutableData* inputIv_;
	NSMutableData* outputIv_;
}

- (void) setEnabled:(BOOL) enabled engine:(EsEngine*) engine connection:(EsConnection*) con;
- (void) handleIncomingMessage:(EsMessage*) message engine:(EsEngine*) engine connection:(EsConnection*) con;
- (void) handleOutgoingMessage:(EsMessage*) message engine:(EsEngine*) engine connection:(EsConnection*) con;
- (void) encryptOutgoingMessage:(NSMutableData*) b;
- (void) decryptIncomingMessage:(NSMutableData*) b;
- (BOOL) enabled;

- (void) prepareCiphers;
- (NSMutableData*) md5HashFromString:(NSString*) s;
- (NSString*) stringFromMpInt:(mp_int*) mp radix:(int) radix;
	
@end

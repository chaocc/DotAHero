//
//  CryptoTools.m
//  cocoa-touch
//
//  Created by Jason von Nieda on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EsCryptoTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"


@implementation EsCryptoTools
+ (NSString*) generatePasswordHash:(NSString*) visiblePasssword hashId:(int) hashId {
	NSString* dataToHash = [NSString stringWithFormat:@"%@___%d", visiblePasssword, hashId];
	const char* bytes = [dataToHash UTF8String];
	unsigned char hash[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1_CTX ctx;
	CC_SHA1_Init(&ctx);
	CC_SHA1_Update(&ctx, bytes, strlen(bytes));
	CC_SHA1_Final(hash, &ctx);
	size_t encodedLength;
	char* encoded = NewBase64Encode(hash, CC_SHA1_DIGEST_LENGTH, 0, &encodedLength);
	NSString* ret = [NSString stringWithCString:encoded encoding:NSASCIIStringEncoding];
	free(encoded);
	return ret;
}
@end

#import "Ed25519PublicKey.h"
#import "NSError+ConvenienceConstructors.h"
#import "NSData+EncodingHelpers.h"

@implementation Ed25519PublicKey


+(Ed25519PublicKey*)publicKeyWithData:(NSData*)data error:(NSError**)error {
	if (data.length != crypto_sign_ed25519_PUBLICKEYBYTES) {
		[NSError set:error
			  domain:@"Ed25519"
				code:1
			  format:@"Public key does not have correct length (expected %d, got %d)", crypto_sign_ed25519_PUBLICKEYBYTES, (int)data.length];
		return nil;
	}
	Ed25519PublicKey *key = [[Ed25519PublicKey alloc] init];
	memcpy(key->pk, data.bytes, crypto_sign_ed25519_PUBLICKEYBYTES);
	return [key autorelease];
}

+(Ed25519PublicKey*)publicKeyWithStringRepresentation:(NSString*)str error:(NSError**)error {
    NSData *keyData = [NSData dataWithLength:crypto_sign_ed25519_PUBLICKEYBYTES fromBase58EncodedString:str error:error];
    if (!keyData) return nil;
    Ed25519PublicKey *key = [[Ed25519PublicKey alloc] init];
	memcpy(key->pk, keyData.bytes, crypto_sign_ed25519_PUBLICKEYBYTES);
	return [key autorelease];
}


-(BOOL)verifySignature:(NSData*)sig forMessage:(NSData*)message error:(NSError**)error {
	if (sig.length != crypto_sign_ed25519_BYTES) {
		[NSError set:error domain:@"Ed25519" code:1 format:@"Signature length %d not as expected %d", (int)sig.length, crypto_sign_ed25519_BYTES];
		return NO;
	}
	int status = crypto_sign_ed25519_verify_detached(sig.bytes, message.bytes, message.length, pk);
	if (status==0) {
		return YES;
	} else {
		[NSError set:error domain:@"Ed25519" code:2 format:@"Signature is not valid"];
		return NO;
	}
}

-(BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[Ed25519PublicKey class]]) {
		Ed25519PublicKey *otherKey = object;
		return memcmp(pk, otherKey->pk, crypto_sign_ed25519_PUBLICKEYBYTES) == 0;
	} else {
		return NO;
	}
}

-(NSUInteger)hash {
	return *(NSUInteger*)pk;
}

-(NSData *)data {
    return [NSData dataWithBytes:pk length:crypto_sign_ed25519_PUBLICKEYBYTES];
}

-(NSString *)stringRepresentation {
    return [[NSData dataWithBytes:pk length:crypto_sign_ed25519_PUBLICKEYBYTES] base58EncodedString];
}

@end

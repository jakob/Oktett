#import "KVPMutableDictionary.h"
#import "NSError+ConvenienceConstructors.h"

@implementation KVPMutableDictionary

-(id)init {
	self = [super init];
	if (self) {
		NSMutableData *d = [[NSMutableData alloc] init];
		self->data = d;
		self->mutableData = d;
	}
	return self;
}

-(BOOL)setData:(NSData*)valueData forDataKey:(NSData*)keyData error:(NSError**)outError {
    if ([self dataForDataKey:keyData]) {
        [NSError set:outError
              domain:@"KVPDictionary"
                code:2 
              format:@"Key already exists"];
        return NO;
    }
    
    if (keyData.length > 255) {
        [NSError set:outError
              domain:@"KVPDictionary"
                code:3 
              format:@"Key too long"];
        return NO;
    }
    
    if (valueData.length > 255) {
        [NSError set:outError
              domain:@"KVPDictionary"
                code:4
              format:@"Value too long"];
        return NO;
    }
    
    uint8_t len;
    len = keyData.length;
    [mutableData appendBytes:&len length:1];
    [mutableData appendData:keyData];
    
    len = valueData.length;
    [mutableData appendBytes:&len length:1];
    [mutableData appendData:valueData];
    
    return YES;
}

-(BOOL)setData:(NSData*)valueData forStringKey:(NSString*)key error:(NSError**)outError {
    return [self setData:valueData forDataKey:[key dataUsingEncoding:NSUTF8StringEncoding] error:outError];    
}

-(BOOL)setString:(NSString*)value forStringKey:(NSString*)key error:(NSError**)outError {
    return [self setData:[value dataUsingEncoding:NSUTF8StringEncoding] forStringKey:key error:outError];
}

-(BOOL)setUInt16:(uint16_t)value forStringKey:(NSString*)key error:(NSError**)outError {
    size_t numBytes = sizeof(value);
    NSMutableData *dataValue = [[NSMutableData alloc] initWithLength:numBytes];
    uint8_t *mutableBytes = [dataValue mutableBytes];
    for (size_t i = 0; i < numBytes; i++) mutableBytes[i] = value >> ((numBytes-1-i)*8);
    BOOL res = [self setData:dataValue forStringKey:key error:outError];
    [dataValue release];
    return res;
}

-(BOOL)setUInt32:(uint32_t)value forStringKey:(NSString*)key error:(NSError**)outError {
    size_t numBytes = sizeof(value);
    NSMutableData *dataValue = [[NSMutableData alloc] initWithLength:numBytes];
    uint8_t *mutableBytes = [dataValue mutableBytes];
    for (size_t i = 0; i < numBytes; i++) mutableBytes[i] = value >> ((numBytes-1-i)*8);
    BOOL res = [self setData:dataValue forStringKey:key error:outError];
    [dataValue release];
    return res;
}

-(BOOL)setUInt64:(uint64_t)value forStringKey:(NSString*)key error:(NSError**)outError {
    size_t numBytes = sizeof(value);
    NSMutableData *dataValue = [[NSMutableData alloc] initWithLength:numBytes];
    uint8_t *mutableBytes = [dataValue mutableBytes];
    for (size_t i = 0; i < numBytes; i++) mutableBytes[i] = value >> ((numBytes-1-i)*8);
    BOOL res = [self setData:dataValue forStringKey:key error:outError];
    [dataValue release];
    return res;
}

-(BOOL)signWithKeyPair:(Ed25519KeyPair*)keyPair key:(NSString*)key error:(NSError**)outError {
    NSMutableData *signaturePlaceholder = [[NSMutableData alloc] initWithLength:96];
    NSData *publicKeyData = keyPair.publicKey.data;
    memcpy(signaturePlaceholder.mutableBytes, publicKeyData.bytes, 32);
    if (![self setData:signaturePlaceholder forStringKey:key error:outError]) {
        [signaturePlaceholder release];
        return NO;
    }
    [signaturePlaceholder release];
    
    NSUInteger signatureOffset = data.length-64;
    NSData *truncatedMessage = [NSData dataWithBytes:data.bytes length:signatureOffset];
    NSData *signature = [keyPair signatureForMessage:truncatedMessage error:outError];
    if (!signature) {
        // Note: there is now a broken signature in data!!
        return NO;
    }
    [mutableData replaceBytesInRange:NSMakeRange(signatureOffset, 64) withBytes:signature.bytes];
    return YES;
}

@end

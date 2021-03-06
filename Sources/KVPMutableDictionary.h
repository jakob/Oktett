#import <Foundation/Foundation.h>
#import "KVPDictionary.h"
#import "Ed25519PublicKey.h"
#import "Ed25519KeyPair.h"

@interface KVPMutableDictionary : KVPDictionary {
    NSMutableData *mutableData;
}

-(BOOL)setData:(NSData*)valueData forDataKey:(NSData*)keyData error:(NSError**)outError;
-(BOOL)setData:(NSData*)valueData forStringKey:(NSString*)key error:(NSError**)outError;
-(BOOL)setString:(NSString*)value forStringKey:(NSString*)key error:(NSError**)outError;
-(BOOL)setUInt16:(uint16_t)value forStringKey:(NSString*)key error:(NSError**)outError;
-(BOOL)setUInt32:(uint32_t)value forStringKey:(NSString*)key error:(NSError**)outError;
-(BOOL)setUInt64:(uint64_t)value forStringKey:(NSString*)key error:(NSError**)outError;
-(BOOL)signWithKeyPair:(Ed25519KeyPair*)keyPair key:(NSString*)key error:(NSError**)outError;

@end

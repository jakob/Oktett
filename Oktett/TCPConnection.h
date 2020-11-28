//
//  TCPConnection.h
//  Oktett
//
//  Created by Jakob on 28.11.20.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IPAddress.h"

@interface TCPConnection : NSObject {
    int tcp_sock;
    IPAddress* remoteAddress;
}

@property(readonly) IPAddress* remoteAddress;

-(id)initWithSocket:(int)sock remoteAddress:(IPAddress*)address;

+(TCPConnection*)connectTo:(IPAddress*)address error:(NSError**)outError;

-(BOOL)sendData:(NSData*)data error:(NSError**)outError;

-(NSData*)receiveDataWithLength:(NSUInteger)length error:(NSError**)outError;

-(void)close;

@end

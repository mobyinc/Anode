//
//  ANUser.h
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject.h"

@interface ANUser : ANObject

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, readonly) BOOL authenticated;

+(void)loginWithUsername:(NSString*)username password:(NSString*)password block:(LoginBlock)block;
+(void)refreshLoginWithBlock:(LoginBlock)block;
+(void)registerDeviceTokenWithData:(NSData*)data block:(CompletionBlock)block;
+(void)logout;

+(ANUser*)currentUser;

@end

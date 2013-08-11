//
//  ANUser.m
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANUser.h"

static ANUser* sharedUser = nil;

@implementation ANUser

+(void)loginWithUsername:(NSString*)username password:(NSString*)password block:(LoginBlock)block
{
    
}

+(void)restoreLoginWithBlock:(LoginBlock)block
{
    
}

+(void)logout
{
    
}

+(ANUser*)currentUser
{
    return sharedUser;
}

@end

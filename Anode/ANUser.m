//
//  ANUser.m
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANUser.h"
#import "Anode.h"

static ANUser* sharedCurrentUser = nil;

@implementation ANUser

+(void)loginWithUsername:(NSString*)username password:(NSString*)password block:(LoginBlock)block
{
    
}

+(void)refreshLoginWithBlock:(LoginBlock)block
{
    
}

+(void)logout
{
    
}

+(ANUser*)currentUser
{
    return sharedCurrentUser;
}

#pragma mark - Special Properties

-(NSString *)username
{
    return [self objectForKey:@"username"];
}

-(void)setUsername:(NSString *)username
{
    [self setObject:username forKey:@"username"];
}

-(NSString *)password
{
    return [self objectForKey:@"password"];
}

-(void)setPassword:(NSString *)password
{
    [self setObject:password forKey:@"password"];
}

@end

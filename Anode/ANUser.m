//
//  ANUser.m
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//


#import "ANUser.h"
#import "ANObject_Private.h"
#import "ANClient_Private.h"
#import "Anode.h"
#import "Anode_Private.h"
#import "ANCache.h"
#import "ANJSONRequestOperation.h"
#import "NSError+Helpers.h"

static ANUser* sharedCurrentUser = nil;


@implementation ANUser

+(void)loginWithUsername:(NSString*)username password:(NSString*)password block:(LoginBlock)block
{
    NSDictionary* parameters = nil;
    
    if (username && password) {
        parameters = @{@"username": username, @"password": password};
    }
    
    NSURLRequest* request = [ANClient requestForVerb:@"POST" type:@"user" objectId:nil action:@"login" parameters:parameters];
    
    ANJSONRequestOperation *operation = [ANJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (block) block(nil, error);
    }];
    
    [operation start];
}

+(void)refreshLoginWithBlock:(LoginBlock)block
{
    if (![ANUser currentUser]) {
        if (block) block(nil, [NSError errorWithDescription:@"Cannot refresh login while logged out."]);
        return;
    }
    
    [ANUser loginWithUsername:nil password:nil block:block];
}

+(void)registerDeviceTokenWithData:(NSData *)data
{
    if (![ANUser currentUser]) {
        NSLog(@"Cannot register device token without current user.");
        return;
    }
    
#warning @"implement
}

+(void)logout
{
    sharedCurrentUser = nil;
    [Anode sharedInstance].userToken = nil;
    [[ANCache sharedInstance] clearObjectForKey:@"/user/current_user"];
}

+(ANUser*)currentUser
{
    if (!sharedCurrentUser) {
        sharedCurrentUser = [[ANCache sharedInstance] objectForKey:@"/user/current_user"];
    }
    
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

//
//  Anode.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "Anode.h"
#import "Anode_Private.h"
#import "ANUser_Private.h"

NSString *const ANErrorKey = @"ANErrorKey";
NSString *const ANErrorOriginalError = @"ANErrorOriginalError";

static Anode* sharedAnodeInstance = nil;

@implementation Anode

+(Anode*)sharedInstance {
    if (!sharedAnodeInstance) {
        sharedAnodeInstance = [[Anode alloc] init];
    }
    
    return sharedAnodeInstance;
}

+(void)initializeWithBaseUrl:(NSString *)url clientToken:(NSString *)token
{
    [Anode sharedInstance].baseUrl = url;
    [Anode sharedInstance].clientToken = token;
    
    if ([ANUser currentUser]) {
        [Anode sharedInstance].userToken = [[ANUser currentUser] token];
    }    
}

+(NSURL *)baseUrl
{
    return [NSURL URLWithString:[Anode sharedInstance].baseUrl];
}

+(NSString *)token
{
    return [Anode sharedInstance].userToken ? [Anode sharedInstance].userToken : [Anode sharedInstance].clientToken;
}



@end

//
//  Anode.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "Anode.h"

static Anode* sharedAnodeInstance = nil;

@interface Anode ()

@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* baseUrl;

@end

@implementation Anode

+(Anode*)sharedInstance {
    if (!sharedAnodeInstance) {
        sharedAnodeInstance = [[Anode alloc] init];
    }
    
    return sharedAnodeInstance;
}

+(void)setBaseUrl:(NSString *)url token:(NSString *)token
{
    [Anode sharedInstance].baseUrl = url;
    [Anode sharedInstance].token = token;
}

+(NSString *)baseUrl
{
    return [Anode sharedInstance].baseUrl;
}

+(NSString *)token
{
    return [Anode sharedInstance].token;
}

@end

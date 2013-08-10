//
//  Anode.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "Anode.h"

static NSString* _clientToken;

@implementation Anode

+(void)setClientToken:(NSString *)token
{
    _clientToken = token;
}

+(NSString *)clientToken
{
    return _clientToken;
}

@end

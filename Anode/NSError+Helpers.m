//
//  NSError+Helpers.m
//  Anode
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "NSError+Helpers.h"

@implementation NSError (Helpers)

+(NSError*)errorWithDescription:(NSString*)description
{
    return [NSError errorWithCode:-1 description:description originalError:nil];
}

+(NSError*)errorWithCode:(NSInteger)code description:(NSString*)description
{
    return [NSError errorWithCode:code description:description originalError:nil];
}

+(NSError*)errorWithCode:(NSInteger)code description:(NSString*)description originalError:(NSError*)originalError
{
    return [NSError errorWithDomain:@"anode" code:code userInfo:@{@"NSLocalizedDescription" : description, @"ANOriginalError" : originalError}];
}

@end

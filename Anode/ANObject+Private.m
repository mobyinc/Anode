//
//  ANObject+Private.m
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject+Private.h"
#import "Anode.h"

@implementation ANObject (Private)

@dynamic type;
@dynamic objectId;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic emptyObject;

-(NSMutableURLRequest *)requestForVerb:(NSString *)verb
{
    NSString* baseUrl = [Anode baseUrl];
    NSString* typeSegment = [[self.type lowercaseString] stringByAppendingString:@"s"]; // TODO: better pluralization
    NSString* url = nil;
    
    if ([verb isEqualToString:@"POST"]) {
        url = [NSString stringWithFormat:@"%@/%@", baseUrl, typeSegment];
    } else if ([verb isEqualToString:@"PUT"]) {
        url = [NSString stringWithFormat:@"%@/%@/%@", baseUrl, typeSegment, self.objectId];
    } else {
        @throw @"invalid http verb";
    }
    
    NSMutableURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:[NSString stringWithFormat:@"Token token=%@", [Anode token]] forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = verb;
    
    return request;
}

@end

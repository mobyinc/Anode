//
//  ANClient.m
//  Anode
//
//  Created by James Jacoby on 8/18/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANClient.h"
#import "ANClient_Private.h"
#import "Anode.h"
#import "NSString+ActiveSupportInflector.h"

@implementation ANClient

-(id)init
{
    self = [super init];
    
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    
    return self;
}

-(NSMutableURLRequest *)requestForVerb:(NSString*)verb
{
    return [self requestForVerb:verb objectId:nil action:nil];
}

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb objectId:(NSNumber*)objectId
{
    return [self requestForVerb:verb objectId:objectId action:nil];
}

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb action:(NSString*)action
{
    return [self requestForVerb:verb objectId:nil action:action];
}

-(NSMutableURLRequest *)requestForVerb:(NSString*)verb objectId:(NSNumber *)objectId action:(NSString*)action
{
    NSString* typeSegment = [self.type pluralizeString];
    NSURL* baseUrl = [Anode baseUrl];
    NSString* path = nil;
    NSURL* url = nil;
    
    if (action && objectId) {
        path = [NSString stringWithFormat:@"%@/%@/%@", typeSegment, objectId, action];
    } else if (objectId) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, objectId];
    } else if (action) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, action];
    } else {
        path = [NSString stringWithFormat:@"%@/", typeSegment];
    }
    
    url = [NSURL URLWithString:path relativeToURL:baseUrl];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Token token=%@", [Anode token]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = verb;
    
    return request;
}

@end

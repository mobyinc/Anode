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
#import "ANJSONRequestOperation.h"
#import "NSString+ActiveSupportInflector.h"

static AFHTTPClient* sharedClient = nil;

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

-(AFHTTPClient *)client
{
    if (!sharedClient) {
        sharedClient = [[AFHTTPClient alloc] initWithBaseURL:[Anode baseUrl]];
        [sharedClient registerHTTPOperationClass:[ANJSONRequestOperation class]];
        [sharedClient setDefaultHeader:@"Accept" value:@"application/json"];
        [sharedClient setDefaultHeader:@"Content-Type" value:@"application/json"];
        [sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=%@", [Anode token]]];
    }
    
    return sharedClient;
}

-(NSMutableURLRequest *)requestForVerb:(NSString*)verb
{
    return [self requestForVerb:verb objectId:nil action:nil parameters:nil];
}

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb objectId:(NSNumber*)objectId
{
    return [self requestForVerb:verb objectId:objectId action:nil parameters:nil];
}

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb action:(NSString*)action
{
    return [self requestForVerb:verb objectId:nil action:action parameters:nil];
}

-(NSMutableURLRequest *)requestForVerb:(NSString*)verb objectId:(NSNumber *)objectId action:(NSString*)action parameters:(NSDictionary*)parameters
{
    NSString* typeSegment = [self.type pluralizeString];
    NSString* path = nil;
    
    if (action && objectId) {
        path = [NSString stringWithFormat:@"%@/%@/%@", typeSegment, objectId, action];
    } else if (objectId) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, objectId];
    } else if (action) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, action];
    } else {
        path = [NSString stringWithFormat:@"%@/", typeSegment];
    }    
    
    NSMutableURLRequest* request = [self.client requestWithMethod:verb path:path parameters:parameters];
    
    return request;
}

@end

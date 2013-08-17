//
//  ANJSONRequestOperation.m
//  Anode
//
//  Created by James Jacoby on 8/17/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANJSONRequestOperation.h"

@implementation ANJSONRequestOperation

+ (instancetype)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
{
    ANJSONRequestOperation *requestOperation = [(ANJSONRequestOperation *)[self alloc] initWithRequest:urlRequest];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            id JSON = [(AFJSONRequestOperation *)operation responseJSON];
            NSString* message = @"unknown error";
            int code = 0;
            
            if (JSON && JSON[@"error"]) {
                @try {
                    message = JSON[@"error"][@"message"] ? JSON[@"error"][@"message"] : @"unspecified error";
                    code = JSON[@"error"][@"code"] ? [JSON[@"error"][@"code"] intValue] : 0;
                }
                @catch (NSException *exception) {
                    NSLog(@"error parsing error response");
                }
            } else if (error && error.code == -1004) {
                message = @"Could not connect to server";
                code = 503;
            }
            
            NSError* friendlyError = [NSError errorWithDomain:@"Anode" code:code userInfo:@{@"NSLocalizedDescription" : message, @"ANOriginalError" : error}];
            
            failure(operation.request, operation.response, friendlyError, JSON);
        }
    }];
    
    return requestOperation;
}

@end

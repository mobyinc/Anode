//
//  ANClient.h
//  Anode
//
//  Created by James Jacoby on 8/18/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTypes.h"

typedef enum {
    kANStatusCodeOk = 200,
    kANStatusCodeBadRequest = 400,
    kANStatusCodeUnauthorized = 401,
    kANStatusCodeServerError = 500,
    kANStatusCodeServiceUnavailable = 503
} ANStatusCode;

@interface ANClient : NSObject

@property (nonatomic, strong, readonly) NSString* type;

@end

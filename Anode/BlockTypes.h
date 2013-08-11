//
//  BlockTypes.h
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

@class ANObject;
@class ANUser;

typedef void (^CompletionBlock) (NSError* error);
typedef void (^ObjectResultBlock) (ANObject* object, NSError* error);
typedef void (^ObjectsResultBlock) (NSArray* objects, NSError* error);
typedef void (^ScalarResultBlock) (NSNumber* value, NSError* error);
typedef void (^LoginBlock) (ANUser* user, NSError* error);

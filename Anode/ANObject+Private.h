//
//  ANObject+Private.h
//  Anode
//
//  Created by James Jacoby on 8/10/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject.h"

@interface ANObject (Private)

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSNumber* objectId;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;
@property (nonatomic, assign) BOOL emptyObject;

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb;

@end

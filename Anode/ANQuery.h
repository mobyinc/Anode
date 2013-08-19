//
//  ANQuery.h
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANClient.h"

typedef enum {
    Descending,
    Ascending    
} Direction;

@interface ANQuery : ANClient

@property (nonatomic, strong) NSNumber* limit;
@property (nonatomic, strong) NSNumber* skip;
@property (nonatomic, strong) NSString* orderBy;
@property (nonatomic, assign) Direction orderDirection;

+(ANQuery*)queryWithType:(NSString*)type;

-(void)findObjectWithId:(NSNumber*)objectId block:(ObjectResultBlock)block;
-(void)findObjectsWithPredicate:(NSPredicate*)predicate block:(ObjectsResultBlock)block;
-(void)findObjectsWithMethod:(NSString*)methodName parameters:(NSDictionary*)parameters block:(ObjectsResultBlock)block;
-(void)countObjectsWithPredicate:(NSPredicate*)predicate block:(ScalarResultBlock)block;

@end

//
//  ANQuery.h
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANClient.h"

/** Use instances of ANQuery to fetch objects from the remote service.
 */

typedef enum {
    kANOrderDirectionDescending,
    kANOrderDirectionAscending
} ANOrderDirection;

typedef enum {
    kANCachePolicyIgnoreCache,
    kANCachePolicyCacheElseNetwork,
    kANCachePolicyNetworkElseCache,
    
} ANCachePolicy;

@interface ANQuery : ANClient

@property (nonatomic, strong) NSNumber* limit;
@property (nonatomic, strong) NSNumber* skip;
@property (nonatomic, strong) NSString* orderBy;
@property (nonatomic, assign) ANOrderDirection orderDirection;
@property (nonatomic, assign) ANCachePolicy cachePolicy;
@property (nonatomic, readonly) BOOL isRelationship;

+(ANQuery*)queryWithType:(NSString*)type;

/** Returns an ANQuery intialized for a relationship query.
 */
+(ANQuery*)queryWithType:(NSString*)type belongingToType:(NSString*)belongsToType throughRelationshipNamed:(NSString*)relationshipName withObjectId:(NSNumber*)objectId;

-(void)findAllObjectsWithBlock:(ObjectsResultBlock)block;
-(void)findObjectsWithBlock:(ObjectsResultBlock)block;
-(void)findObjectWithId:(NSNumber*)objectId block:(ObjectResultBlock)block;
-(void)findObjectsWithPredicate:(NSPredicate*)predicate block:(ObjectsResultBlock)block;
-(void)findObjectsWithMethod:(NSString*)methodName parameters:(NSDictionary*)parameters block:(ObjectsResultBlock)block;
-(void)countObjectsWithPredicate:(NSPredicate*)predicate block:(ScalarResultBlock)block;
-(void)fetchScalarWithMethod:(NSString*)methodName parameters:(NSDictionary*)parameters block:(ScalarResultBlock)block;

@end

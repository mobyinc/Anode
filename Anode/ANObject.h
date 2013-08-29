//
//  ANObject.h
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANClient.h"
#import "ANQuery.h"

/** ANObject is the primary interface used for inspection and modification of remote objects.
 */

@interface ANObject : ANClient<NSCoding>

/** @name Initialization
 */

/** Initialize a new ANObject with an object type.
 
 The object type represents the singualar, lowercase name of the remote resource. 
 
    For example: 
    A model stored in a products table, and represented by the Product class, would require a type identifier of "product"
 
 The type parameter may not be changed once initialized and serves to scope all network interactions to the associated resource.
 
 When objects are retrieved via an ANQuery, the type parameter is automatically set.
 
 @param type The object type
 @returns An empty ANObject, initialized with the specified type
 */
+(ANObject*)objectWithType:(NSString*)type;

/** Initialize a new object with an object type and object Id
 
 Similar to objectWithType:, this method builds an empty object with the added objectId attribute. 
 
 Use this method to initialize an ANObject you already know the objectId of. The object may then be refreshed by calling reloadWithBlock: or remotely destroyed by calling destroyWithBlock:.
 
 Before being refresh, an ANObject in this state may not be saved.
 
 @param type The object type
 @returns An empty ANObject, initialized with the specified type and objectId
 */
+(ANObject*)objectWithType:(NSString*)type objectId:(NSNumber*)objectId;

/** @name Accessing special attributes
 
 All ANObjects include objectId, createdAt, and updatedAt in the attributes list. These special attributes may be accessed via read-only propertiesof the same name.
 */

@property (nonatomic, strong, readonly) NSNumber* objectId;
@property (nonatomic, strong, readonly) NSDate* createdAt;
@property (nonatomic, strong, readonly) NSDate* updatedAt;

/** @name Inspection and modification of attributes
 */
-(void)setObject:(id)object forKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;
-(id)objectForKey:(NSString*)key;

/** @name Commiting and refreshing changes 
 */

-(void)save;
-(void)saveWithBlock:(CompletionBlock)block;
-(void)reload;
-(void)reloadWithBlock:(CompletionBlock)block;
-(void)destroy;
-(void)destroyWithBlock:(CompletionBlock)block;

/** @name Obtaining a relationship query
 */

/** Returns an ANQuery initalized with a releationship that exists on the current.
 
 This is a shortcut for calling [ANQuery queryWithType: belongingToType: throughRelationshipNamed: withObjectId:];
 
 An ANQuery initialized in this way is appropriate for returning objects in a has-many relationship. The resuting query will return objects of the object type associated with the relationship.
 
 @param relationshipName The name of the has-many relationship
 @returns An ANQuery initialized to return objects of type relationshipName which belong to the current object
 */
-(ANQuery*)queryForRelationshipNamed:(NSString*)relationshipName;

@end

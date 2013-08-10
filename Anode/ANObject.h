//
//  ANObject.h
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "Anode.h"

@interface ANObject : NSObject

@property (nonatomic, strong, readonly) NSString* type;
@property (nonatomic, strong, readonly) NSNumber* objectId;
@property (nonatomic, strong, readonly) NSDate* createdAt;
@property (nonatomic, strong, readonly) NSDate* updatedAt;

+(ANObject*)objectWithType:(NSString*)type;
+(ANObject*)objectWithType:(NSString*)type objectId:(NSNumber*)objectId;

-(void)setObject:(id)object forKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;
-(id)objectForKey:(NSString*)key;

-(void)saveAsynchronously;
-(void)saveAsynchronouslyWithBlock:(CompletionBlock)block;
-(void)reloadWithBlock:(CompletionBlock)block;

@end

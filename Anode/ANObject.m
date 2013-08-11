//
//  ANObject.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject.h"
#import "ANObject+Private.h"
#import "Anode.h"

// TODO: better constant for this?
#define NIL_INDICATOR @"<nil>"

@implementation ANObject

+(ANObject*)objectWithType:(NSString*)type
{
    ANObject* object = [[ANObject alloc] init];
    object.type = type;
    
    return object;
}

+(ANObject*)objectWithType:(NSString*)type objectId:(NSNumber*)objectId
{
    ANObject* object = [[ANObject alloc] init];
    object.type = type;
    object.objectId = objectId;
    object.emptyObject = YES; // cannot be saved, for placeholder / relationships only
    
    return object;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        _attributes = [NSMutableDictionary dictionaryWithCapacity:10];
        _dirtyAttributes = [NSMutableSet setWithCapacity:10];
    }
    
    return self;
}

-(void)setObject:(id)object forKey:(NSString*)key
{
    id existingValue = _attributes[key];
    
    if (![existingValue isEqual:object]) {
        [_dirtyAttributes addObject:key];
        _attributes[key] = object;
    }
}

-(void)removeObjectForKey:(NSString*)key
{
    [self setObject:NIL_INDICATOR forKey:key];
}

-(id)objectForKey:(NSString*)key
{
    id object = _attributes[key];
    
    if ([object isEqualToString:NIL_INDICATOR])
        return nil;
    else
        return object;
}

-(void)save
{
    [self saveWithBlock:nil];
}

-(void)saveWithBlock:(CompletionBlock)block
{
    NSString* verb = self.objectId ? @"PUT" : @"POST";
    NSMutableURLRequest* request = [self requestForVerb:verb];
    
    // what do we post back to server? serialized object?
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:nil];
    [operation start];
}

-(void)reloadWithBlock:(CompletionBlock)block
{
#warning TODO: Implement
}

@end

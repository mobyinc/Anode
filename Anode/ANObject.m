//
//  ANObject.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject.h"
#import "ANClient_Private.h"
#import "ANObject_Private.h"
#import "Anode.h"
#import "ANJSONRequestOperation.h"
#import "NSError+Helpers.h"
#import "NSString+TypeDetection.h"
#import "NSString+ActiveSupportInflector.h"

@implementation ANObject

+(ANObject*)objectWithType:(NSString*)type
{
    ANObject* object = [[ANObject alloc] init];
    object.type = type.lowercaseString;
    
    return object;
}

+(ANObject*)objectWithType:(NSString*)type objectId:(NSNumber*)objectId
{
    ANObject* object = [[ANObject alloc] init];
    object.type = type.lowercaseString;
    object.objectId = objectId;
    object.emptyObject = YES; // id was manually specified and therefore cannot be saved unless reloaded first
    
    return object;
}

+(ANObject*)objectWithJSON:(NSDictionary *)node error:(NSError**)error
{
    NSString* type = node[@"__type"];
    
    if (type) {
        ANObject* object = [ANObject objectWithType:type];
        [ANObject applyAttributesWithDictionary:node toObject:object error:error];
        return object;
    } else {
        *error = [NSError errorWithDescription:@"Missing type attribute in server response."];
        return nil;
    }
}

-(id)init
{
    self = [super init];
    
    if (self) {
        _dirty = NO;
        
        self.emptyObject = NO;
        self.attributes = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return self;
}

-(void)setObject:(id)object forKey:(NSString*)key
{
    id existingValue = _attributes[key];
    
    if (![existingValue isEqual:object]) {
        _dirty = YES;
        
        if (object) {
            self.attributes[key] = object;
        } else {
            [self removeObjectForKey:key];
        }
    }
}

-(void)removeObjectForKey:(NSString*)key
{
    [self setObject:[NSNull null] forKey:key];
}

-(id)objectForKey:(NSString*)key
{
    id object = self.attributes[key];

    return object;
}

-(void)save
{
    [self saveWithBlock:nil];
}

-(void)saveWithBlock:(CompletionBlock)block
{
    if (!_dirty) {
        if (block) block(self, nil);
        return;
    } else if (self.emptyObject) {
        if (block) block(self, [NSError errorWithDescription:@"Cannot save an empty object. Load by id or reload first."]);
        return;
    }
    
    NSString* verb = self.objectId ? @"PUT" : @"POST";
    NSData* httpBody = [self attributesToJSON];
    
    [self performRequestWithVerb:verb httpBody:httpBody block:block];
}

-(void)reload
{
    [self reloadWithBlock:nil];
}

-(void)reloadWithBlock:(CompletionBlock)block
{
    if (!self.objectId) {
        if (block) block(self, [NSError errorWithDescription:@"Cannot reload object with no object id."]);
        return;
    }

    [self performRequestWithVerb:@"GET" httpBody:nil block:block];
}

-(void)destroy
{
    [self destroyWithBlock:nil];
}

-(void)destroyWithBlock:(CompletionBlock)block
{
    if (!self.objectId) {
        if (block) block(self, [NSError errorWithDescription:@"Cannot destroy object with no object id."]);
        return;
    }
    
    [self performRequestWithVerb:@"DELETE" httpBody:nil block:^(id object, NSError *error) {
        if (!error) {
            [self.attributes removeObjectForKey:@"id"];
        }
        
        if (block) block(self, error);
    }];
}

#pragma mark - Special Attributes

-(NSNumber*)objectId
{
    return [self objectForKey:@"id"];
}

-(void)setObjectId:(NSNumber*)objectId
{
    [self setObject:objectId forKey:@"id"];
}

-(NSDate*)createdAt
{
    return [self objectForKey:@"created_at"];
}

-(NSDate*)updatedAt
{
    return [self objectForKey:@"updated_at"];
}

#pragma mark - Private

-(void)performRequestWithVerb:(NSString*)verb httpBody:(NSData*)httpBody block:(CompletionBlock)block
{
    NSMutableURLRequest* request = [self requestForVerb:verb objectId:self.objectId];
    request.HTTPBody = httpBody;
    
    ANJSONRequestOperation *operation = [ANJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSError* error = nil;
        
        if (![request.HTTPMethod isEqualToString:@"DELETE"]) {
            [self applyAttributesWithJSONResponse:JSON error:&error];
        }
        
        if (block) block(self, error);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (block) block(nil, error);
    }];
    
    [operation start];
}

-(void)applyAttributesWithJSONResponse:(id)rootNode error:(NSError**)error
{
    if (rootNode && [rootNode isKindOfClass:[NSDictionary class]] && rootNode[@"id"]) {        
        [ANObject applyAttributesWithDictionary:rootNode toObject:self error:error];
    } else if (error) {
        *error = [NSError errorWithDescription:@"Missing object root node in server response."];
    }
}

+(void)applyAttributesWithDictionary:(NSDictionary*)node toObject:(ANObject*)object error:(NSError**)error
{
    object.attributes = [NSMutableDictionary dictionary];
    object.dirty = NO;
    object.emptyObject = NO;
    
    for (id key in node.allKeys) {
        id value = node[key];
        
        // handle special types
        // others pass straight through
        if ([value isKindOfClass:[NSString class]]) {
            if ([value isDate]) {
                value = [object.dateFormatter dateFromString:value];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:[value count]];
            for (NSDictionary* childNode in value) {
                ANObject* newObject = [ANObject objectWithJSON:childNode error:error];
                
                if (!*error && newObject) {
                    [newArray addObject:newObject];
                } else {
                    break;
                }
            }
            
            value = newArray;
        }
        
        if (*error) return;
        
        object.attributes[key] = value;
    }
}

-(NSData*)attributesToJSON
{
    NSError* serializationError = nil;
    NSMutableDictionary* attributesToSend = [NSMutableDictionary dictionaryWithDictionary:self.attributes];
    
    // strip unwanted attributes
    [attributesToSend removeObjectForKey:@"id"];
    [attributesToSend removeObjectForKey:@"created_at"];
    [attributesToSend removeObjectForKey:@"updated_at"];
    
    // handle special data types
    for (id key in attributesToSend.allKeys) {
        id value = attributesToSend[key];
        
        if ([value isKindOfClass:[NSDate class]]) {
            NSString* dateString = [self.dateFormatter stringFromDate:value];
            [attributesToSend setObject:dateString forKey:key];
        }
    }
    
    NSData* JSON = [NSJSONSerialization dataWithJSONObject:attributesToSend options:0 error:&serializationError];
    
    if (serializationError) {
        return nil;
    } else {
        return JSON;
    }
}

@end

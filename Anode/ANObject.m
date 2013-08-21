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

-(void)applyAttributesWithJSONResponse:(id)JSON error:(NSError**)error
{
    id object = JSON[self.type] ? JSON[self.type] : JSON;
    
    if (object && object[@"id"]) {
        self.attributes = [NSMutableDictionary dictionaryWithDictionary:object];
        _dirty = NO;
        _emptyObject = NO;
        
        for (id key in self.attributes.allKeys) {
            id value = self.attributes[key];
            
            // check for date objects
            if ([value isKindOfClass:[NSString class]]) {
                NSString* dateTimeRegex = @"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}[+-]\\d{4}";
                NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", dateTimeRegex];
                
                if ([pred evaluateWithObject:value]) {
                    NSDate* date = [self.dateFormatter dateFromString:value];
                    [self.attributes setObject:date forKey:key];
                }
            }
            else if ([value isKindOfClass:[NSArray class]]) {
                NSLog(@"hurray, an array");
            }
        }
        
    } else if (error) {
        *error = [NSError errorWithDescription:@"Missing object attributes in server response."];
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

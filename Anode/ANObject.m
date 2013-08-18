//
//  ANObject.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANObject.h"
#import "Anode.h"
#import "ANJSONRequestOperation.h"
#import "NSError+Helpers.h"
#import "NSString+ActiveSupportInflector.h"

@interface ANObject ()

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSNumber* objectId;
@property (nonatomic, assign) BOOL emptyObject;

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb;
-(void)performRequestWithVerb:(NSString*)verb httpBody:(NSData*)httpBody block:(CompletionBlock)block;
-(void)applyAttributesWithJSONResponse:(id)JSON error:(NSError**)error;

@end

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
        _attributes = [NSMutableDictionary dictionaryWithCapacity:10];
        _dirty = NO;
        _emptyObject = NO;
    }
    
    return self;
}

-(void)setObject:(id)object forKey:(NSString*)key
{
    id existingValue = _attributes[key];
    
    if (![existingValue isEqual:object]) {
        _dirty = YES;
        _attributes[key] = object;
    }
}

-(void)removeObjectForKey:(NSString*)key
{
    [self setObject:[NSNull null] forKey:key];
}

-(id)objectForKey:(NSString*)key
{
    id object = _attributes[key];

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
    NSError* serializationError = nil;
    NSData* httpBody = nil;
    NSMutableDictionary* attributesToSend = [NSMutableDictionary dictionaryWithDictionary:_attributes];
    
    // strip unwanted attributes
    [attributesToSend removeObjectForKey:@"id"];
    [attributesToSend removeObjectForKey:@"created_at"];
    [attributesToSend removeObjectForKey:@"updated_at"];
    
    httpBody = [NSJSONSerialization dataWithJSONObject:attributesToSend options:0 error:&serializationError];
    
    if (serializationError) {
        if (block) block(self, [NSError errorWithDescription:@"JSON serializarion error"]);
        return;
    }
    
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
            [self removeObjectForKey:@"id"];
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

-(NSMutableURLRequest *)requestForVerb:(NSString*)verb
{
    NSString* typeSegment = [self.type pluralizeString];
    NSURL* baseUrl = [Anode baseUrl];
    NSString* path = nil;
    NSURL* url = nil;
    
    if ([verb isEqualToString:@"POST"]) {
        path = [NSString stringWithFormat:@"%@/", typeSegment];
    } else if ([verb isEqualToString:@"GET"] || [verb isEqualToString:@"PUT"] || [verb isEqualToString:@"DELETE"]) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, self.objectId];
    } else {
        @throw @"Invalid http verb.";
    }
    
    url = [NSURL URLWithString:path relativeToURL:baseUrl];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Token token=%@", [Anode token]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = verb;
    
    return request;
}

-(void)performRequestWithVerb:(NSString*)verb httpBody:(NSData*)httpBody block:(CompletionBlock)block
{
    NSMutableURLRequest* request = [self requestForVerb:verb];
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
    id object = JSON[self.type];
    
    if (object && object[@"id"]) {
        _attributes = [NSMutableDictionary dictionaryWithDictionary:object];
        _dirty = NO;
        _emptyObject = NO;
    } else if (error) {
        *error = [NSError errorWithDescription:@"Missing object attributes in server response."];
    }
}

@end

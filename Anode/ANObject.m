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

// TODO: better constant for this?
#define NIL_INDICATOR @"<nil>"

@interface ANObject ()

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSNumber* objectId;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;
@property (nonatomic, assign) BOOL emptyObject;

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb;

@end

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
        _dirty = NO;
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
    
    NSError* error = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:_attributes options:0 error:&error];
    
    NSLog(@"%@ - %@", verb, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);        
    
    ANJSONRequestOperation *operation = [ANJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (block) block(nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (block) block(error);
    }];
    
    [operation start];
}

-(void)reloadWithBlock:(CompletionBlock)block
{
#warning TODO: Implement
}

#pragma mark - Private

-(NSMutableURLRequest *)requestForVerb:(NSString *)verb
{
    NSString* typeSegment = [[self.type lowercaseString] stringByAppendingString:@"s"]; // TODO: better pluralization
    NSURL* baseUrl = [Anode baseUrl];
    NSString* path = nil;
    NSURL* url = nil;
    
    if ([verb isEqualToString:@"POST"]) {
        path = [NSString stringWithFormat:@"%@/", typeSegment];
    } else if ([verb isEqualToString:@"PUT"]) {
        path = [NSString stringWithFormat:@"%@/%@", typeSegment, self.objectId];
    } else {
        @throw @"invalid http verb";
    }
    
    url = [NSURL URLWithString:path relativeToURL:baseUrl];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Token token=%@", [Anode token]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = verb;
    
    return request;
}

@end

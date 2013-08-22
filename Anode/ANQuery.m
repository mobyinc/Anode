//
//  ANQuery.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANQuery.h"
#import "ANCache.h"
#import "ANClient_Private.h"
#import "ANObject_Private.h"
#import "ANJSONRequestOperation.h"
#import "NSString+ActiveSupportInflector.h"
#import "NSError+Helpers.h"
#import "NSData+MD5.h"

@interface ANQuery ()

@property (nonatomic, strong) NSString* type;

@end

@implementation ANQuery

+(ANQuery*)queryWithType:(NSString *)type
{
    ANQuery* query = [[ANQuery alloc] init];
    query.type = type.lowercaseString;
    query.skip = [NSNumber numberWithInt:0];
    query.limit = [NSNumber numberWithInt:100];
    query.orderDirection = kANOrderDirectionAscending;
    query.cachePolicy = kANCachePolicyIgnoreCache;
    
    return query;
}

-(void)findAllObjectsWithBlock:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:nil skip:nil limit:nil block:block];
}

-(void)findObjectsWithBlock:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:nil block:block];
}

-(void)findObjectWithId:(NSNumber *)objectId block:(ObjectResultBlock)block
{
    NSMutableURLRequest* request = [self requestForVerb:@"GET" objectId:objectId action:nil parameters:nil];
    
    [self fetchObjectsWithRequest:request block:^(NSArray *objects, NSError *error) {
        if (objects && objects.count == 1) {
            block(objects[0], nil);
        } else {
            block(nil, error);
        }
    }];
}

-(void)findObjectsWithPredicate:(NSPredicate *)predicate block:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:predicate skip:self.skip limit:self.limit block:block];
}

-(void)findObjectsWithMethod:(NSString*)methodName parameters:(NSDictionary*)parameters block:(ObjectsResultBlock)block
{
    NSMutableURLRequest* request = [self requestForVerb:@"GET" objectId:nil action:methodName parameters:parameters];
    
    [self fetchObjectsWithRequest:request block:block];
}

-(void)countObjectsWithPredicate:(NSPredicate*)predicate block:(ScalarResultBlock)block
{
    
}


#pragma mark - Private

-(void)findObjectsWithPredicate:(NSPredicate *)predicate skip:(NSNumber*)skip limit:(NSNumber*)limit block:(ObjectsResultBlock)block
{
    NSMutableURLRequest* request = nil;
    
    if (predicate || limit) {
        request = [self requestForVerb:@"POST" action:@"query"];        
        request.HTTPBody = [self jsonWithPredicate:predicate skip:skip limit:limit orderBy:self.orderBy orderDirection:self.orderDirection];
    } else {
        request = [self requestForVerb:@"GET"];
    }
    
    [self fetchObjectsWithRequest:request block:block];
}

-(void)fetchObjectsWithRequest:(NSURLRequest*)request block:(ObjectsResultBlock)block
{
    if (self.cachePolicy == kANCachePolicyIgnoreCache) {
        [self fetchObjectsFromNetworkWithRequest:request block:block];
    } else if (self.cachePolicy == kANCachePolicyNetworkElseCache) {
        [self fetchObjectsFromNetworkWithRequest:request block:^(NSArray *objects, NSError *error) {
            if (error) {
                if (error.code == kANStatusCodeServiceUnavailable) {
                    [self fetchObjectsFromNetworkWithRequest:request block:block];
                } else if (block) {
                    block(nil, error);
                }
            } else if (block) {
                block(objects, nil);
            }
        }];
    } else if (self.cachePolicy == kANCachePolicyCacheElseNetwork) {
        id objects = [self fetchObjectsFromCacheWithRequest:request];
        
        if (objects && block) {
            block(objects, nil);
        } else {
            [self fetchObjectsFromNetworkWithRequest:request block:block];
        }
    }
}

-(void)fetchObjectsFromNetworkWithRequest:(NSURLRequest*)request block:(ObjectsResultBlock)block
{
    ANJSONRequestOperation *operation = [ANJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSError* error = nil;
        
        NSMutableArray* objects = [NSMutableArray array];
        
        if ([JSON isKindOfClass:[NSArray class]]) {
            for (id node in JSON) {
                ANObject* object = [ANObject objectWithJSON:node error:&error];
                
                if (!error && object) {
                    [objects addObject:object];
                } else {
                    break;
                }
            }
        } else if ([JSON isKindOfClass:[NSDictionary class]]) {
            ANObject* object = [ANObject objectWithJSON:JSON error:&error];
            
            if (!error && object) {
                [objects addObject:object];
            }
        } else {
            error = [NSError errorWithDescription:@"Unexpected root node in server response."];
        }
        
        if (block) block(objects, error);
        
        if (!error && self.cachePolicy != kANCachePolicyIgnoreCache) {
            [self commitObjectsToCacheWithRequest:request objects:objects];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (block) block(nil, error);
    }];
    
    [operation start];
}

-(id)fetchObjectsFromCacheWithRequest:(NSURLRequest*)request
{
    NSString* cacheKey = [self cacheKeyForRequest:request];
    return [[ANCache sharedInstance] objectForKey:cacheKey];
}

-(BOOL)commitObjectsToCacheWithRequest:(NSURLRequest*)request objects:(id<NSCoding>)objects
{
    NSString* cacheKey = [self cacheKeyForRequest:request];
    return [[ANCache sharedInstance] setObject:objects forKey:cacheKey];
}

-(NSData*)jsonWithPredicate:(NSPredicate*)predicate skip:(NSNumber*)skip limit:(NSNumber*)limit orderBy:(NSString*)orderBy orderDirection:(ANOrderDirection)orderDirection
{
    NSError* serializationError = nil;
    NSMutableDictionary* components = [NSMutableDictionary dictionary];
    NSData* JSON = nil;
    
    if (limit) components[@"limit"] = limit;
    if (skip) components[@"skip"] = skip;
    
    if (orderBy) {
        components[@"order_by"] = orderBy;
        components[@"order_direction"] = orderDirection == kANOrderDirectionDescending ? @"DESC" : @"ASC";
    }
    
    if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate* comparison = (NSComparisonPredicate*)predicate;
        NSString* operator = [self stringWithOperatorType:comparison.predicateOperatorType];
        NSString* left = [NSString stringWithFormat:@"%@", comparison.leftExpression];
        NSString* right = [NSString stringWithFormat:@"%@", comparison.rightExpression];
        
        components[@"predicate"] = @{@"left" : left,
                                     @"operator" : operator,
                                     @"right" : right};
    }
    
    JSON = [NSJSONSerialization dataWithJSONObject:components options:0 error:&serializationError];
    
    if (serializationError) {
        return nil;
    } else {
        return JSON;
    }
}

-(NSString*)stringWithOperatorType:(NSPredicateOperatorType)type
{
    switch (type) {
        case NSEqualToPredicateOperatorType:
            return @"eq";
        case NSGreaterThanPredicateOperatorType:
            return @"gt";
        case NSGreaterThanOrEqualToPredicateOperatorType:
            return @"gteq";
        case NSLessThanPredicateOperatorType:
            return @"lt";
        case NSLessThanOrEqualToPredicateOperatorType:
            return @"lteq";
        default:
            @throw @"Unsupported predicate operator type";
            break;
    }
}

-(NSString*)cacheKeyForRequest:(NSURLRequest*)request;
{
    NSData* codedData = [NSKeyedArchiver archivedDataWithRootObject:request];
    return [codedData MD5];
}

@end

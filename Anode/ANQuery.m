//
//  ANQuery.m
//  Anode
//
//  Created by James Jacoby on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANQuery.h"
#import "ANClient_Private.h"
#import "ANObject_Private.h"
#import "ANJSONRequestOperation.h"
#import "NSString+ActiveSupportInflector.h"

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
    query.orderDirection = Descending;
    
    return query;
}

-(void)findAllObjectsWithBlock:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:nil limit:nil block:block];
}

-(void)findObjectsWithBlock:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:nil block:block];
}

-(void)findObjectWithId:(NSNumber *)objectId block:(ObjectResultBlock)block
{
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"id = %@", objectId];
    [self findObjectsWithPredicate:pre limit:[NSNumber numberWithInt:1] block:^(NSArray *objects, NSError *error) {
        if (objects && objects.count == 1) {
            block(objects[0], nil);
        } else {
            block(nil, error);
        }
    }];
}

-(void)findObjectsWithPredicate:(NSPredicate *)predicate block:(ObjectsResultBlock)block
{
    [self findObjectsWithPredicate:predicate limit:self.limit block:block];
}

-(void)findObjectsWithPredicate:(NSPredicate *)predicate limit:(NSNumber*)limit block:(ObjectsResultBlock)block
{
    NSMutableURLRequest* request = nil;
    
    if (predicate || limit)
        [self requestForVerb:@"POST" action:@"query"];
    else
        [self requestForVerb:@"GET"];
    
    NSData* httpBody = [self jsonWithPredicate:predicate limit:limit skip:self.skip orderBy:self.orderBy orderDirection:self.orderDirection];
    request.HTTPBody = httpBody;
    
    ANJSONRequestOperation *operation = [ANJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSError* error = nil;
        NSString* key = [self.type pluralizeString];
        NSMutableArray* objects = [NSMutableArray array];
        id objectsInfo = JSON[key];
        
        for (id objectInfo in objectsInfo) {
            ANObject* object = [ANObject objectWithType:self.type];
            [object applyAttributesWithJSONResponse:objectInfo error:&error];
            
            if (error) {
                continue;
            } else {
                [objects addObject:object];
            }
        }
        
        if (block) block(objects, error);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (block) block(nil, error);
    }];
    
    [operation start];
    
}

#pragma mark - Private

-(NSData*)jsonWithPredicate:(NSPredicate*)predicate limit:(NSNumber*)limit skip:(NSNumber*)skip orderBy:(NSString*)orderBy orderDirection:(Direction)orderDirection
{
    NSError* serializationError = nil;
    NSMutableDictionary* components = [NSMutableDictionary dictionary];
    NSData* JSON = nil;
    
    components[@"limit"] = limit;
    components[@"skip"] = skip;
    
    if (orderBy) {
        components[@"order_by"] = orderBy;
        components[@"order_direction"] = orderDirection == Descending ? @"DESC" : @"ASC";
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

@end

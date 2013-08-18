//
//  NSString+Inflection.h
//  Anode
//
//  Created by James Jacoby on 8/18/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Inflection)

-(NSString*)pluralizeString;
-(NSString*)singularizeString;

@end

@interface ActiveSupportInflector : NSObject {
    NSMutableSet* uncountableWords;
    NSMutableArray* pluralRules;
    NSMutableArray* singularRules;
}

-(void)addInflectionsFromFile:(NSString*)path;
-(void)addInflectionsFromDictionary:(NSDictionary*)dictionary;

-(void)addUncountableWord:(NSString*)string;
-(void)addIrregularRuleForSingular:(NSString*)singular plural:(NSString*)plural;
-(void)addPluralRuleFor:(NSString*)rule replacement:(NSString*)replacement;
-(void)addSingularRuleFor:(NSString*)rule replacement:(NSString*)replacement;

-(NSString*)pluralize:(NSString*)string;
-(NSString*)singularize:(NSString*)string;

@end

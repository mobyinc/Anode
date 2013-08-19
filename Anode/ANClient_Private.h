//
//  ANClient_Private.h
//  Anode
//
//  Created by James Jacoby on 8/18/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANClient.h"

@interface ANClient ()

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;

-(NSMutableURLRequest*)requestForVerb:(NSString*)verb;
-(NSMutableURLRequest*)requestForVerb:(NSString*)verb objectId:(NSNumber*)objectId;
-(NSMutableURLRequest*)requestForVerb:(NSString*)verb action:(NSString*)action;
-(NSMutableURLRequest*)requestForVerb:(NSString*)verb objectId:(NSNumber *)objectId action:(NSString*)action;

@end

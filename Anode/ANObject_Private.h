//
//  ANObject_Private.h
//  Anode
//
//  Created by James Jacoby on 8/18/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <Anode/Anode.h>

@interface ANObject ()

@property (nonatomic, strong) NSNumber* objectId;
@property (nonatomic, assign) BOOL emptyObject;
@property (nonatomic, strong) NSMutableDictionary* attributes;

-(void)performRequestWithVerb:(NSString*)verb httpBody:(NSData*)httpBody block:(CompletionBlock)block;
-(void)applyAttributesWithJSONResponse:(id)JSON error:(NSError**)error;

@end

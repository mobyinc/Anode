//
//  ANCache.h
//  Anode
//
//  Created by FourtyTwo on 8/21/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANCache : NSObject

+(ANCache*)sharedInstance;

-(id)objectForKey:(NSString*)key;
-(BOOL)setObject:(id<NSCoding>)object forKey:(NSString*)key;
-(void)clearObjectForKey:(NSString*)key;

@end

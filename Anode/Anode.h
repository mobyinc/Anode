//
//  Anode.h
//  Anode
//
//  Created by FourtyTwo on 8/9/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

@class ANObject;
@class ANUser;

#import <Anode/ANObject.h>
#import <Anode/ANQuery.h>
#import <Anode/ANUser.h>
#import <Anode/BlockTypes.h>

@interface Anode : NSObject

+(void)setBaseUrl:(NSString*)url token:(NSString*)token;
+(NSURL*)baseUrl;
+(NSString*)token;

@end


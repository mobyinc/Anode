//
//  ANCache.m
//  Anode
//
//  Created by FourtyTwo on 8/21/13.
//  Copyright (c) 2013 Moby, Inc. All rights reserved.
//

#import "ANCache.h"

static ANCache* sharedCache = nil;

@interface ANCache ()

@property (nonatomic, strong) NSString* cachePath;
@property (nonatomic, assign) long maxCacheSize;

-(void)pruneCache;
-(long)cacheSize;

@end

@implementation ANCache

+(ANCache *)sharedInstance
{
    if (!sharedCache) {
        sharedCache = [[ANCache alloc] init];
    }
    
    return sharedCache;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        self.maxCacheSize = 20 * 1024; // 20 mb
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        self.cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/Anode_Object_Cache"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return self;
}

-(id<NSCoding>)objectForKey:(NSString*)key
{
    NSFileManager* fileManager = [NSFileManager defaultManager];    
    NSString* path = [self pathForStorageKey:key];
    
    if ([fileManager fileExistsAtPath:path]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } else {
        return nil;
    }
}

-(BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    NSString* path = [self pathForStorageKey:key];
    BOOL result = [NSKeyedArchiver archiveRootObject:object toFile:path];
    
    // periodically prune cache
    if (arc4random() % 5 == 0) {
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            [self pruneCache];
        }];
    }
    
    return result;
}

#pragma mark - Private

-(void)pruneCache
{
    if ([self cacheSize] > self.maxCacheSize) {
        // TODO: get rid of some baggage
    }
}

-(long)cacheSize
{
    NSArray* filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.cachePath error:nil];
    NSEnumerator* filesEnumerator = [filesArray objectEnumerator];
    NSString* fileName;
    unsigned long long int fileSize = 0;
        
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary* fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cachePath stringByAppendingPathComponent:fileName] error:nil];
        if (fileDictionary) fileSize += [fileDictionary fileSize];
    }
        
    return fileSize / 1024;
}

-(NSString*)pathForStorageKey:(NSString*)key
{    
    NSString* filename = [NSString stringWithFormat:@"%@.obj", key];
    return [self.cachePath stringByAppendingPathComponent:filename];
}

@end

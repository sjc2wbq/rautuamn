//
//  AIFileManager.h
//  AIFileManager
//
//  Created by mouxiaochun on 15/8/28.
//  Copyright (c) 2015年 mouxiaochun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFileManager : NSObject

+ (NSString *)homeDirectory ;
+ (NSString *)documentDirectory ;
+ (NSString *)tempDirectory ;
+ (NSString *)cacheDirectory ;
+ (NSString *)userDirectory;

+ (BOOL)fileIsExistAtPath:(NSString *)path ;
+ (BOOL)createDirectoryAtPath:(NSString *)path ;
+ (void)removeFileAtPath:(NSString *)path;

+ (NSString *) setObject:(NSData*)data forKey:(NSString*)key;
+ (id)objectForKey:(NSString *)key;

@end

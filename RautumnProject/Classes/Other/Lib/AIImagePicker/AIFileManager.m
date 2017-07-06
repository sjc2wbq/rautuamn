//
//  AIFileManager.m
//  AIFileManager
//
//  Created by mouxiaochun on 15/8/28.
//  Copyright (c) 2015年 mouxiaochun. All rights reserved.
//

#import "AIFileManager.h"
static NSTimeInterval cacheTime =  (double)604800;

@implementation AIFileManager

+ (NSString *)homeDirectory {
    NSString *path = NSHomeDirectory();
    return path;
}

+ (NSString *)documentDirectory {

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    return directory;
}

+ (NSString *)tempDirectory {
  
    NSString *directory = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
    return directory;
    
}

+ (NSString *)cacheDirectory {

    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
    return directory;
}

+ (NSString *)userDirectory {

    NSString *userDirectory = [self.documentDirectory stringByAppendingPathComponent:@"User"];
#warning 一般userId为当前用户的唯一标识做为文件名
    NSString *userId  = @"xxxxxxx";
    if (userId.length > 0) {
        userDirectory = [userDirectory stringByAppendingPathComponent: userId];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:userDirectory isDirectory:&isDir]) {
        
        BOOL s = [fileManager createDirectoryAtPath:userDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (s == YES) {
         
            
        }
    }
    
    return userDirectory;
}

+ (BOOL)fileIsExistAtPath:(NSString *)path {

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}


+ (BOOL)createDirectoryAtPath:(NSString *)path {

    BOOL flag = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
    return flag;
}

+ (void)removeFileAtPath:(NSString *)path {

    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}



+ (NSString *) setObject:(NSData*)data forKey:(NSString*)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:self.userDirectory isDirectory:&isDir]) {
       BOOL s = [fileManager createDirectoryAtPath:self.userDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (s == YES) {
            

        }
    }
    NSString *filename = [self.userDirectory stringByAppendingPathComponent:key];
    NSError *error;
    @try {
        BOOL success = [data writeToFile:filename options:NSDataWritingAtomic error:&error ];
        
        if (success) {
            // NSLog(@"缓存成功：%@",key);
        }
    }
    @catch (NSException * e) {
        //TODO: error handling maybe
    }
    return filename;
}

+ (id)objectForKey:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.userDirectory stringByAppendingPathComponent:key];
    
    if ([fileManager fileExistsAtPath:filename])
    {
        NSDate *modificationDate = [[fileManager attributesOfItemAtPath:filename error:nil] objectForKey:NSFileModificationDate];
        if ([modificationDate timeIntervalSinceNow] > cacheTime) {
            [fileManager removeItemAtPath:filename error:nil];
        } else {
            NSData *data = [NSData dataWithContentsOfFile:filename];
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            return object;
        }
    }
    return nil;

}

@end

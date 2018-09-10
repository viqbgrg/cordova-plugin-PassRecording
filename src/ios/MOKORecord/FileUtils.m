//
//  FileUtils.m
//  RecordingDemo
//
//  Created by Embrace on 2017/6/28.
//
//

#import "FileUtils.h"

@implementation FileUtils

+(NSString *)getTempPath{
    /*
     获取这些目录路径的方法：
     1，获取家目录路径的函数：
     NSString *homeDir = NSHomeDirectory();
     2，获取Documents目录路径的方法：
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *docDir = [paths objectAtIndex:0];
     3，获取Caches目录路径的方法：
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
     NSString *cachesDir = [paths objectAtIndex:0];
     4，获取tmp目录路径的方法：
     NSString *tmpDir = NSTemporaryDirectory();
     5，获取应用程序程序包中资源文件路径的方法：
     例如获取程序包中一个图片资源（apple.png）路径的方法：
     NSString *imagePath = [[NSBundle mainBundle] pathForResource:@”apple” ofType:@”png”];
     UIImage *appleImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
     代码中的mainBundle类方法用于返回一个代表应用程序包的对象。
     */
    NSString* tempPath = NSTemporaryDirectory();
    
    //    NSString* userAccountPath = [docPath stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"nameAccount"]];
    
    NSString* tempMediaPath = [tempPath stringByAppendingPathComponent:@"tempFile"];
    
    BOOL isDir = NO;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL existed = [fm fileExistsAtPath:tempMediaPath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        
        [fm createDirectoryAtPath:tempMediaPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return tempMediaPath;
}

+(void)deleteTempPath{
    NSString* path = [FileUtils getTempPath];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fm fileExistsAtPath:path isDirectory:&isDir];
    
    NSError* error = nil;
    if (existed) {
        [fm removeItemAtPath:path error:&error];
        NSLog(@"deleteError:%@", error);
    }
}

+(void)deleteFileByPath:(NSString *)path{
    if (!path) {
        return;
    }
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fm fileExistsAtPath:path isDirectory:&isDir];
    
    NSError* error = nil;
    if (existed) {
        [fm removeItemAtPath:path error:&error];
        NSLog(@"deleteError:%@", error);
    }
}

+(long long)getFileSize:(NSString *)filePath{
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    long long size = [fileHandle seekToEndOfFile];
    //    NSLog(@"文件大小:::: %lld", size);
    return size;
}

@end

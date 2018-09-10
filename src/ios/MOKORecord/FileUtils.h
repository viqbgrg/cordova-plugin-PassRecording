//
//  FileUtils.h
//  RecordingDemo
//
//  Created by Embrace on 2017/6/28.
//
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

/**

 *
 *  @brief 获取temp路径
 *
 *  @return temp路径
 */
+(NSString*)getTempPath;

/**

 *
 *  @brief 删除temp路径
 */
+(void)deleteTempPath;

/**

 *
 *  @brief 删除文件
 *
 *  @param path 文件路径
 */
+(void)deleteFileByPath:(NSString*)path;

/**
 *
 *
 *  @brief 获取文件大小(单位/byte)
 *
 *  @param filePath 文件路径
 *
 *  @return 文字大小/字节  /1024 = KB   / 1024 = M
 */
+(long long)getFileSize:(NSString*)filePath;


@end

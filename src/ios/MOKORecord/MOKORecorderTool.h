//
//  MOKOSecretTrainRecorder.h
//  MOKORecord
//
//  Created by Spring on 2017/4/26.
//  Copyright © 2017年 Spring. All rights reserved.
//  新建密训录音播放工具

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FileUtils.h"

typedef void(^ReturnMp3UrlBlock)(NSURL *mp3Url);
@class MOKORecorderTool;
@protocol MOKOSecretTrainRecorderDelegate <NSObject>

@optional
- (void)recorder:(MOKORecorderTool *)recorder didstartRecoring:(int)no;
- (void)recordToolDidFinishPlay:(MOKORecorderTool *)recorder;
@end
@interface MOKORecorderTool : NSObject

//录音工具的单例
+ (instancetype)sharedRecorder;

//开始录音
- (void)startRecording;

//停止录音
- (void)stopRecording;

//播放录音文件
- (void)playRecordingFile;

//停止播放录音文件
- (void)stopPlaying;

//销毁录音文件
- (void)destructionRecordingFile;

//录音对象
@property (nonatomic, strong) AVAudioRecorder *recorder;

//播放器对象
@property (nonatomic, strong) AVAudioPlayer *player;

//更新图片的代理
@property (nonatomic, assign) id<MOKOSecretTrainRecorderDelegate> delegate;

//录音文件地址（pcm格式）
@property (nonatomic, strong) NSURL *recordFileUrl;

//录音源文件地址
@property (nonatomic, strong) NSString *audioFileSavePath;
//文件夹地址

@property (nonatomic, strong) NSString *audioTemporarySavePath;

//录音文件地址（mp3格式）
@property (nonatomic, strong) NSURL *recordMp3Url;

//传值block
@property (nonatomic, copy) ReturnMp3UrlBlock returnMp3Block;

-(void)returnMp3Block:(ReturnMp3UrlBlock)block;

@end

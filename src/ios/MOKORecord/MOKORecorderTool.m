//
//  MOKOSecretTrainRecorder.m
//  MOKORecord
//
//  Created by Spring on 2017/4/26.
//  Copyright © 2017年 Spring. All rights reserved.
//

#import "MOKORecorderTool.h"
#import "lame.h"
#define MOKOSecretTrainRecordFielName @"lvRecord.wav"

@interface MOKORecorderTool()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>


@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation MOKORecorderTool

static MOKORecorderTool *instance = nil;
#pragma mark - 单例
+ (instancetype)sharedRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (void)startRecording
{
    // 录音时停止播放 删除曾经生成的文件
    [self stopPlaying];
    [self destructionRecordingFile];
    // 真机环境下需要的代码
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.recorder record];
}

- (void)updateImage
{
    [self.recorder updateMeters];
    
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    //NSLog(@"%f", result);
    int no = 0;
    if (result > 0 && result <= 1.3) {
        no = 1;
    } else if (result > 1.3 && result <= 2) {
        no = 2;
    } else if (result > 2 && result <= 3.0) {
        no = 3;
    } else if (result > 3.0 && result <= 3.0) {
        no = 4;
    } else if (result > 5.0 && result <= 10) {
        no = 5;
    } else if (result > 10 && result <= 40) {
        no = 6;
    } else if (result > 40) {
        no = 7;
    }
    if ([self.delegate respondsToSelector:@selector(recorder:didstartRecoring:)])
    {
        [self.delegate recorder:self didstartRecoring: no];
    }
    else
    {
        
    }
}
- (void)stopRecording
{
    if ([self.recorder isRecording])
    {
        [self.recorder stop];
    }
}
- (void)playRecordingFile
{
    [self.recorder stop];// 播放时停止录音
    // 正在播放就返回
    if ([self.player isPlaying])
    {
        return;
    }
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:&error];
    self.player.delegate = self;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}

- (void)stopPlaying
{
    [self.player stop];
}

#pragma mark - 懒加载
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        // 1.获取沙盒地址
        self.audioTemporarySavePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        self.audioFileSavePath = [self.audioTemporarySavePath stringByAppendingPathComponent:MOKOSecretTrainRecordFielName];
        self.recordFileUrl = [NSURL fileURLWithPath:self.audioFileSavePath];
        NSLog(@"%@", self.audioFileSavePath);
        
        // 3.设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        // 音频格式
        setting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
        // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        setting[AVSampleRateKey] = @(8000.0);
        // 音频通道数 1 或 2
        setting[AVNumberOfChannelsKey] = @(1);
        // 线性音频的位深度  8、16、24、32
        setting[AVLinearPCMBitDepthKey] = @(16);
        setting[AVLinearPCMIsFloatKey] = @(YES);
        //录音的质量
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (void)destructionRecordingFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl)
    {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    //录音结束
    
    [NSThread detachNewThreadSelector:@selector(audio_PCMtoMP3) toTarget:self withObject:nil];
    
}
#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //录音播放结束
    if ([self.delegate respondsToSelector:@selector(recordToolDidFinishPlay:)])
    {
        [self.delegate recordToolDidFinishPlay:self];
    }
}

#pragma mark --- 转换为 mp3
- (void)audio_PCMtoMP3
{
    
    NSString *mp3FileName = [self.audioTemporarySavePath lastPathComponent];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    
    
    NSString *path = [FileUtils getTempPath];
    
    NSString * mp3FilePath;
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    
    mp3FilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",[formater stringFromDate:[NSDate date]]]];
    
    
    
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([self.audioFileSavePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 4000.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        self.recordMp3Url = [NSURL fileURLWithPath:mp3FilePath];
        
        if (self.returnMp3Block != nil) {
            self.returnMp3Block(self.recordMp3Url);
        }
        
        
    }
    
}

// Block
-(void)returnMp3Block:(ReturnMp3UrlBlock)block {
    self.returnMp3Block = block;
}

//filepath

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
    
    NSString* tempMediaPath = [tempPath stringByAppendingPathComponent:@"tempMedia"];
    
    BOOL isDir = NO;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL existed = [fm fileExistsAtPath:tempMediaPath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        
        [fm createDirectoryAtPath:tempMediaPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return tempMediaPath;
}


@end

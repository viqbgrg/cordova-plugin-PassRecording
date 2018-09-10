//
//  PassRecording.m
//  RecordingDemo
//
//  Created by Embrace on 2017/6/25.
//
//

#import "PassRecording.h"
#define kFakeTimerDuration       1
#define kMaxRecordDuration       60     //最长录音时长
#define kRemainCountingDuration  10     //剩余多少秒开始倒计时

#define Start_X 20.0f           // 第一个按钮的X坐标
#define Width_Space 3.0f        // 2个按钮之间的横间距
#define Height_Space 20.0f      // 竖间距

// 获取屏幕尺寸
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHight [UIScreen mainScreen].bounds.size.height
// 适配
#define DevicesScale ([UIScreen mainScreen].bounds.size.height==480?1.00:[UIScreen mainScreen].bounds.size.height==568?1.00:[UIScreen mainScreen].bounds.size.height==667?1.17:1.29)

// 颜色
#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]




// 设备类型
#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]

//屏幕宽度相对iPhone6屏幕宽度的比例
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f


@implementation PassRecording

static UIVisualEffectView *_effectView;
static UIView *blackView;
- (void)passRecordingMethod:(CDVInvokedUrlCommand *)command {
    
    
    self.hasPendingOperation = YES;
    __weak PassRecording *WeakSelf = self;
    WeakSelf.latestCommand = command;
    NSLog(@"self.callbackId : %@",command.callbackId);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    _effectView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHight);
    _effectView.alpha = 0.2;
    [window addSubview:_effectView];
    
    blackView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHight - 60), kScreenWidth, 60)];
    //    blackView.backgroundColor = [UIColor whiteColor];
    blackView.alpha = 0.2;
    [window addSubview:blackView];
    
    /**
     点击退出手势
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissMissView)];
    [_effectView addGestureRecognizer:tap];
    
    
    
    
    /**
     Share Content
     */
    CGFloat bt_width =  75 * DevicesScale;
    if(kScreenHight == 568) {
        bt_width = 85 *DevicesScale;
    }
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHight - 40,kScreenWidth,40)];
    //        shareView.backgroundColor = [UIColor greenColor];
    
    shareView.tag = 441;
    [window addSubview:shareView];
    
    
    self.recordButton = [MOKORecordButton buttonWithType:UIButtonTypeCustom];
    self.recorder = [MOKORecorderTool sharedRecorder];
    self.recorder.delegate = self;
    self.recordButton.frame = CGRectMake(0, 0, kScreenWidth, 40);
    self.recordButton.backgroundColor = [UIColor whiteColor];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.recordButton.layer.cornerRadius = 4;
    self.recordButton.clipsToBounds = YES;
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    shareView.userInteractionEnabled = YES;
    [shareView addSubview:self.recordButton];
    
    //录音相关
    [self toDoRecord:command.callbackId];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
    _effectView.contentView.alpha = 0;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1, 1);
        _effectView.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
    
}




// 页面消失
- (void)dissMissView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *shareView = [window viewWithTag:441];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    shareView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:0.01f animations:^{
        shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
        _effectView.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [shareView removeFromSuperview];
        [_effectView removeFromSuperview];
        [blackView removeFromSuperview];
    }];
    
}

#pragma mark ---- 录音全部状态的监听 以及视图的构建 切换
-(void)toDoRecord:(id)command
{
    __weak typeof(self) weak_self = self;
    //手指按下
    self.recordButton.recordTouchDownAction = ^(MOKORecordButton *sender){
        //如果用户没有开启麦克风权限,不能让其录音
        if (![weak_self canRecord]) return;
        
        NSLog(@"开始录音");
        if (sender.highlighted) {
            sender.highlighted = YES;
            [sender setButtonStateWithRecording];
        }
        [weak_self.recorder startRecording];
        weak_self.currentRecordState = MOKORecordState_Recording;
        [weak_self dispatchVoiceState];
    };
    
    
    
    //手指抬起
    self.recordButton.recordTouchUpInsideAction = ^(MOKORecordButton *sender){
        NSLog(@"完成录音");
        [sender setButtonStateWithNormal];
        [weak_self.recorder stopRecording];
        weak_self.currentRecordState = MOKORecordState_Normal;
        [weak_self dispatchVoiceState];
        
        [weak_self.recorder returnMp3Block:^(NSURL *mp3Url) {
            self.str = mp3Url.absoluteString;
            NSLog(@"str :+++: %@",_str);
            
            
            [weak_self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:weak_self.str] callbackId:command];
            
            
        }];
        
        //        NSLog(@"self.latestCommand.callbackId +_+: %@",command);
        
        
        
        [self dissMissView];
        
    };
    
    //手指滑出按钮
    self.recordButton.recordTouchUpOutsideAction = ^(MOKORecordButton *sender){
        NSLog(@"取消录音");
        [sender setButtonStateWithNormal];
        weak_self.currentRecordState = MOKORecordState_Normal;
        [weak_self dispatchVoiceState];
    };
    
    //中间状态  从 TouchDragInside ---> TouchDragOutside
    self.recordButton.recordTouchDragExitAction = ^(MOKORecordButton *sender){
        weak_self.currentRecordState = MOKORecordState_ReleaseToCancel;
        [weak_self dispatchVoiceState];
    };
    
    //中间状态  从 TouchDragOutside ---> TouchDragInside
    self.recordButton.recordTouchDragEnterAction = ^(MOKORecordButton *sender){
        NSLog(@"继续录音");
        weak_self.currentRecordState = MOKORecordState_Recording;
        [weak_self dispatchVoiceState];
    };
}

- (void)startFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
    self.fakeTimer = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(onFakeTimerTimeOut) userInfo:nil repeats:YES];
    [_fakeTimer fire];
}

- (void)stopFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
}

- (void)onFakeTimerTimeOut
{
    self.duration += kFakeTimerDuration;
    NSLog(@"+++duration+++ %f",self.duration);
    float remainTime = kMaxRecordDuration-self.duration;
    if ((int)remainTime == 0) {
        self.currentRecordState = MOKORecordState_Normal;
        [self dispatchVoiceState];
    }
    else if ([self shouldShowCounting]) {
        self.currentRecordState = MOKORecordState_RecordCounting;
        [self dispatchVoiceState];
        [self.voiceRecordCtrl showRecordCounting:remainTime];
    }
    else
    {
        [self.recorder.recorder updateMeters];
        float   level = 0.0f;                // The linear 0.0 .. 1.0 value we need.
        
        float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
        float decibels = [self.recorder.recorder peakPowerForChannel:0];
        if (decibels < minDecibels)
        {
            level = 0.0f;
        }
        else if (decibels >= 0.0f)
        {
            level = 1.0f;
        }
        else
        {
            float   root            = 2.0f;
            float   minAmp          = powf(10.0f, 0.05f * minDecibels);
            float   inverseAmpRange = 1.0f / (1.0f - minAmp);
            float   amp             = powf(10.0f, 0.05f * decibels);
            float   adjAmp          = (amp - minAmp) * inverseAmpRange;
            level = powf(adjAmp, 1.0f / root);
        }
        
        NSLog(@"平均值 %f", level );
        //        NSLog(@"平均值 %f", level * 120);
        
        [self.voiceRecordCtrl updatePower:level];
    }
}
- (BOOL)shouldShowCounting
{
    if (self.duration >= (kMaxRecordDuration-kRemainCountingDuration) && self.duration < kMaxRecordDuration && self.currentRecordState != MOKORecordState_ReleaseToCancel) {
        return YES;
    }
    return NO;
}

- (void)resetState
{
    [self stopFakeTimer];
    self.duration = 0;
    self.canceled = YES;
}

- (void)dispatchVoiceState
{
    if (_currentRecordState == MOKORecordState_Recording) {
        self.canceled = NO;
        [self startFakeTimer];
    }
    else if (_currentRecordState == MOKORecordState_Normal)
    {
        [self resetState];
    }
    [self.voiceRecordCtrl updateUIWithRecordState:_currentRecordState];
}

- (MOKORecordShowManager *)voiceRecordCtrl
{
    if (_voiceRecordCtrl == nil) {
        _voiceRecordCtrl = [MOKORecordShowManager new];
    }
    return _voiceRecordCtrl;
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                               delegate:nil
                                      cancelButtonTitle:@"关闭"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
    return bCanRecord;
}

@end

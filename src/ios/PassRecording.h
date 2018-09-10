//
//  PassRecording.h
//  RecordingDemo
//
//  Created by Embrace on 2017/6/25.
//
//

#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MOKORecorderTool.h"
#import "MOKORecordShowManager.h"
#import "MOKORecordButton.h"


@interface PassRecording : CDVPlugin
<MOKOSecretTrainRecorderDelegate>
@property (nonatomic, strong) MOKORecordShowManager *voiceRecordCtrl;
@property (nonatomic, assign) MOKORecordState currentRecordState;
@property (nonatomic, strong) NSTimer *fakeTimer;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, strong) MOKORecordButton *recordButton;
@property (nonatomic, strong) MOKORecorderTool *recorder;
- (void)passRecordingMethod:(CDVInvokedUrlCommand *)command;
@property (nonatomic, assign) CDVInvokedUrlCommand *latestCommand;
@property (readwrite, assign) BOOL hasPendingOperation;
@property (nonatomic, copy)  NSString *str;

- (void)dissMissView;
@end

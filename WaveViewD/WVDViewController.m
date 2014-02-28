//
//  WVDViewController.m
//  WaveViewD
//
//  Created by Jing on 14-2-28.
//  Copyright (c) 2014年 jing. All rights reserved.
//

#import "WVDViewController.h"
#import "WVDWaveView.h"
#import <AVFoundation/AVFoundation.h>

@interface WVDViewController ()
{
    AVAudioRecorder *_recorder;
}

@property (weak, nonatomic) IBOutlet WVDWaveView *defaultWaveView;
@property (weak, nonatomic) IBOutlet WVDWaveView *mirrorWaveView;
@property (weak, nonatomic) NSTimer *timer;

@end

@implementation WVDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initAudioRecorder];
    [self initWaveViewDefault];
    [self initWaveViewMirror];
}

- (void)initWaveViewDefault
{
    [self.defaultWaveView setWaveType:kWaveTypeDefault MaxValue:0 MinValue:-160];
    [self.defaultWaveView setBanchmarkHeight:20];
}

- (void)initWaveViewMirror
{
    [self.mirrorWaveView setWaveType:kWaveTypeMirror MaxValue:0 MinValue:-160];
    [self.mirrorWaveView setZeroPointValue:-55];
}

- (void)initAudioRecorder
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [directories objectAtIndex:0];
    NSString *recordPath = [documentPath stringByAppendingPathComponent:@"record.m4a"];
    
    NSURL *recordURL = [NSURL fileURLWithPath:recordPath];
    
    NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                             [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                             [NSNumber numberWithInt:1],AVNumberOfChannelsKey, nil];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:recordURL settings:setting error:nil];
    [_recorder setMeteringEnabled:YES];
    [_recorder prepareToRecord];
    
}

- (IBAction)startRecording:(id)sender
{
    [_recorder record];
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(waveUpdate) userInfo:nil repeats:YES];
}

- (IBAction)pauseRecording:(id)sender
{
    [_recorder pause];
}

- (void)waveUpdate
{
    [_recorder updateMeters];
    
    double volume = [_recorder averagePowerForChannel:0];
    [self.defaultWaveView startWavingWithValue:volume];
    [self.mirrorWaveView startWavingWithValue:volume];
}

@end

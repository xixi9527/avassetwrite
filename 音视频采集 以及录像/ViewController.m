//
//  ViewController.m
//  音视频采集 以及录像
//
//  Created by 喻佳珞 on 2017/7/24.
//  Copyright © 2017年 喻佳珞. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CurrentTimes.h"

@interface ViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSesstion;
    AVCaptureVideoDataOutput *_vOutput;
    dispatch_queue_t _captureQueue;
    AVAssetWriter *_writer;
    AVAssetWriterInput *_aWriterInput;
    AVAssetWriterInput *_vWriterInput;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    
    [self setCapture];//音视频
    
    [self setAVAsset];//写mp4的
 
    
}

///采集回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    static NSInteger offset = 0;
    
    if (_writer.status == AVAssetWriterStatusUnknown) {
        [_writer startWriting];
        [_writer startSessionAtSourceTime:CMTimeMake(0, 0)];
       offset = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).value;
    }
    
    
    if (captureOutput == _vOutput) {
        NSLog(@"视频");
    } else {
        NSLog(@"音频");
    }
    
    
    
    
    
    
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    NSLog(@"%lld",time.value / time.timescale);
    
    
}

- (void)setAVAsset
{
    /// 以当前时间创建存储路径
    //    NSLog(@"mp4 path :%@",path);
    
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",[NSString getCurrentTime]]];
    _writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeMPEG4 error:nil];
    
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,[NSNumber numberWithInt:48000],AVSampleRateKey,[NSNumber numberWithInt:1],AVNumberOfChannelsKey,nil];
    _aWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    
    
    NSDictionary *videSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,[NSNumber numberWithInt:720],AVVideoWidthKey,[NSNumber numberWithInt:1024],AVVideoHeightKey,nil];
    _vWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videSettings];
    
    
    if ([_writer canAddInput:_vWriterInput]) {
        [_writer addInput:_vWriterInput];
        _vWriterInput.expectsMediaDataInRealTime = YES;
    }
    else
    {
        NSLog(@"vWriter 添加失败");
    }
    
    if ([_writer canAddInput:_aWriterInput]) {
        [_writer addInput:_aWriterInput];
        _aWriterInput.expectsMediaDataInRealTime = YES;
    }
    else
    {
        NSLog(@"aWriter 添加失败");
    }
    

}

//采集设置
- (void)setCapture
{
    _captureQueue = dispatch_queue_create("capture", NULL);
    _captureSesstion = [[AVCaptureSession alloc] init];
    
    
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    
    
    if ([_captureSesstion canAddInput:videoInput]) {
        [_captureSesstion addInput:videoInput];
    }
    else
    {
        NSLog(@"video input add file");
    }
    
    if ([_captureSesstion canAddInput:audioInput])
    {
        [_captureSesstion addInput:audioInput];
    }
    else
    {
        NSLog(@"audio input add fail");
    }
    
    _vOutput = [[AVCaptureVideoDataOutput alloc] init];
    AVCaptureAudioDataOutput *aOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    if ([_captureSesstion canAddOutput:_vOutput])
    {
        [_captureSesstion addOutput:_vOutput];
        
        NSDictionary *videSetting = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],kCVPixelBufferPixelFormatTypeKey,nil];
        
        [_vOutput setVideoSettings:videSetting];
        AVCaptureConnection *connection = [_vOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [_vOutput setSampleBufferDelegate:self queue:_captureQueue];
    }
    else
    {
        NSLog(@"video output add fail");
    }
    
    if ([_captureSesstion canAddOutput:aOutput])
    {
        [_captureSesstion addOutput:aOutput];
        [aOutput setSampleBufferDelegate:self queue:_captureQueue];
    }
    else
    {
        NSLog(@"video output add fail");
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_captureSesstion startRunning];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

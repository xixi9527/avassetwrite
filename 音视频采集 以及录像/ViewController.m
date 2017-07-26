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
#import <AssetsLibrary/AssetsLibrary.h>
#import "PQMP4Writer.h"

#import <time.h>
#import <sys/time.h>

@interface ViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSesstion;
    AVCaptureVideoDataOutput *_vOutput;
    dispatch_queue_t _captureQueue;
    AVAssetWriter *_writer;
    AVAssetWriterInput *_aWriterInput;
    AVAssetWriterInput *_vWriterInput;
    
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    
    
    
    
    AVCaptureVideoPreviewLayer *_playerLayer;
    BOOL _isWriter;
    NSURL *_fileUrl;
    
    int64_t startTime;
    int64_t curStamp;
    
    
    PQMP4Writer *_pqwriter;
    
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    startTime = 0;
    curStamp = 0;
    
    [self setCapture];//音视频
    
    
//    [self setAVAsset];//写mp4的
    [self addSwtich];
    
    _pqwriter = [[PQMP4Writer alloc] init];
    
    
}

- (void)addSwtich
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn setTitle:@"结束" forState:UIControlStateSelected];
    btn.bounds = CGRectMake(0, 0, 40, 30);
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [_captureSesstion startRunning];
}

- (void)switchBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        
        _isWriter = YES;
    }
    else
    {
        _isWriter = NO;
        [_pqwriter endWriterCallBack:^(NSURL *fileUrl) {
           
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:fileUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"%@",error);
                } else {
                    NSLog(@"%@ 保存成功到相册",fileUrl);
                }
               
            }];
        }];
    }
    
}



///采集回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
//    NSLog(@"%@",[NSThread currentThread]);
    if ( _vOutput == captureOutput) {
        if (_isWriter) {
            
            if (!_pqwriter.isWriting) {
                [_pqwriter startWriterWithSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            }
        }
        if (_pqwriter.isWriting) {
            [_pqwriter writerVsampleBuffer:sampleBuffer];
        }
    } else {
        if (_isWriter) {
            if (_pqwriter.isWriting) {
                [_pqwriter writerAsampleBuffer:sampleBuffer];
            }
        }
        
    }
    
}

- (void)setAVAsset
{
    /// 以当前时间创建存储路径
    //    NSLog(@"mp4 path :%@",path);
    
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",[NSString getCurrentTime]]];
    _fileUrl = [NSURL fileURLWithPath:path];
    _writer = [[AVAssetWriter alloc] initWithURL:_fileUrl fileType:AVFileTypeMPEG4 error:nil];
    
    
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
    
    NSDictionary *pixelBufferOptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,nil];

    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_vWriterInput sourcePixelBufferAttributes:pixelBufferOptions];
    
    
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
    
    
    
    AVCaptureVideoPreviewLayer *playerLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSesstion];
    playerLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:playerLayer];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

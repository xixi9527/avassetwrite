//
//  PQMP4Writer.m
//  音视频采集 以及录像
//
//  Created by 喻佳珞 on 2017/7/25.
//  Copyright © 2017年 喻佳珞. All rights reserved.
//

#import "PQMP4Writer.h"
#import "NSString+CurrentTimes.h"
@interface PQMP4Writer()
{
    AVAssetWriter *_writer;
    AVAssetWriterInput *_aWriterInput;
    AVAssetWriterInput *_vWriterInput;
    
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    NSURL *_fileUrl;
    dispatch_queue_t _writerQueue;
    CMTime _endTime;
}
@end

@implementation PQMP4Writer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _writerQueue = dispatch_queue_create("writerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)startWriterWithSourceTime:(CMTime)starTime
{
    
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
        NSLog(@"video Writer 添加失败");
        return NO;
    }
    
    if ([_writer canAddInput:_aWriterInput]) {
        [_writer addInput:_aWriterInput];
        _aWriterInput.expectsMediaDataInRealTime = YES;
    }
    else
    {
        NSLog(@"audio Writer 添加失败");
        return NO;
    }
    
    NSDictionary *pixelBufferOptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,nil];
    
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_vWriterInput sourcePixelBufferAttributes:pixelBufferOptions];
    if (![_writer startWriting])
    {
        NSLog(@"开启失败");
        return NO;
    }
    [_writer startSessionAtSourceTime:starTime];
    _isWriting = YES;
    return YES;
}


- (void)writerAsampleBuffer:(CMSampleBufferRef)sampleBuff
{
    dispatch_sync(_writerQueue, ^{
        if ([_aWriterInput isReadyForMoreMediaData] && _writer.status == AVAssetWriterStatusWriting) {
            if (![_aWriterInput appendSampleBuffer:sampleBuff]) {
                NSLog(@"audio samplebuff 添加失败");
            }
        }
        
//        
    });
    
}

- (void)writerVsampleBuffer:(CMSampleBufferRef)sampleBuff
{
    dispatch_sync(_writerQueue, ^{
        if ([_vWriterInput isReadyForMoreMediaData] && _writer.status == AVAssetWriterStatusWriting) {
            if (![_vWriterInput appendSampleBuffer:sampleBuff]) {
                NSLog(@"video samplebuff 添加失败");
            }
        }
        
        _endTime = CMSampleBufferGetPresentationTimeStamp(sampleBuff);

    });
    
}

- (void)writerPixeBuffer:(CVPixelBufferRef)pixe andStampTime:(CMTime)time
{
    dispatch_sync(_writerQueue, ^{
        if ([_vWriterInput isReadyForMoreMediaData] && _writer.startWriting == AVAssetWriterStatusWriting) {
            if (![_adaptor appendPixelBuffer:pixe withPresentationTime:time]) {
                NSLog(@"video samplebuff 添加失败");
            }
            
        }
        CVPixelBufferRelease(pixe);
    });
    _endTime = time;
}

- (void)endWriterCallBack:(void (^)(NSURL *))back
{
    [_writer finishWritingWithCompletionHandler:^{
        back(_fileUrl);
    }];
    _isWriting = NO;
    _writer =  nil;
    _adaptor = nil;
    _aWriterInput = nil;
    _vWriterInput = nil;
}

@end

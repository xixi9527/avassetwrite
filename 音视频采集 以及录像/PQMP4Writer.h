//
//  PQMP4Writer.h
//  音视频采集 以及录像
//
//  Created by 喻佳珞 on 2017/7/25.
//  Copyright © 2017年 喻佳珞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface PQMP4Writer : NSObject





@property (nonatomic , assign)BOOL isWriting;


/**
 开启writer

 @param starTime 开始时间
 */
- (BOOL)startWriterWithSourceTime:(CMTime)starTime;


/**
 pixebuff 视频数据写入
 */
- (void)writerPixeBuffer:(CVPixelBufferRef )pixe andStampTime:(CMTime)time;

/**
 sampleBuff 视频数据写入
*/
- (void)writerVsampleBuffer:(CMSampleBufferRef )sampleBuff;


/**
 sampleBuff 音频数据写入 
 */
- (void)writerAsampleBuffer:(CMSampleBufferRef )sampleBuff;


/**
 结束录制
 */
- (void)endWriterCallBack:(void(^)(NSURL *fileUrl))back;



@end

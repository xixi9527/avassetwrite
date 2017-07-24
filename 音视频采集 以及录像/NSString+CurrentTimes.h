//
//  NSString+CurrentTimes.h
//  音视频采集 以及录像
//
//  Created by 喻佳珞 on 2017/7/25.
//  Copyright © 2017年 喻佳珞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CurrentTimes)
/**
 获取时间戳
 
 @return timeString
 */
+ (NSString*)getCurrentTimestamp;

/**
 获取当前时间yyyymmddhhmmss
 
 @return timeString
 */
+ (NSString *)getCurrentTime;
@end

//
//  NSString+CurrentTimes.m
//  音视频采集 以及录像
//
//  Created by 喻佳珞 on 2017/7/25.
//  Copyright © 2017年 喻佳珞. All rights reserved.
//

#import "NSString+CurrentTimes.h"

@implementation NSString (CurrentTimes)



+(NSString*)getCurrentTime {
    
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString*dateTime = [formatter stringFromDate:[NSDate date]];
    
    return dateTime;
    
}





+(NSString*)getCurrentTimestamp{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    return timeString;
    
}


@end

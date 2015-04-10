//
//  NSDate+JavaScriptTimestamp.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NSDate+JavaScriptTimestamp.h"

@implementation NSDate (JavaScriptTimestamp)

+ (NSDate *)dateFromJavascriptTimestamp:(id)timestamp {
    
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) ([timestamp doubleValue] / 1000)];
    
}

+ (NSNumber *)javascriptTimestampNow {
    return [NSNumber numberWithDouble:round([[NSDate date] timeIntervalSince1970] * 1000)];
}

+ (NSNumber *)javascriptTimestampFromDate:(NSDate *)date {
    return [NSNumber numberWithDouble:round([date timeIntervalSince1970] * 1000)];
}

-(NSString *)tableViewCellTimeString{
    NSTimeInterval timeInterval = [self timeIntervalSinceNow];
    BOOL isOver24HoursOld =  timeInterval < -86400;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (isOver24HoursOld) {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        return [dateFormatter stringFromDate:self];
    }else{
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        return [dateFormatter stringFromDate:self];
    }
}

@end

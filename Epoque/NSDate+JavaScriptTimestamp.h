//
//  NSDate+JavaScriptTimestamp.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JavaScriptTimestamp)


// convert this date to a javascript timestamp
+ (NSNumber *)javascriptTimestampNow;

// convert a string to an NSDate
+ (NSDate *)dateFromJavascriptTimestamp:(id)timestamp;

// convert a date back to a long (in ms)
+ (NSNumber *)javascriptTimestampFromDate:(NSDate *)date;

-(NSString  *)tableViewCellTimeString;

@end

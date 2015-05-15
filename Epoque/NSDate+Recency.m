//
//  NSDate+Recency.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/14/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NSDate+Recency.h"

@implementation NSDate (Recency)

-(BOOL)isFresh{
    NSInteger hours = [self hoursBetween:self and:[NSDate date]];
    return hours < 3;
}


-(BOOL)isOld{
    NSInteger hours = [self hoursBetween:self and:[NSDate date]];
    return hours > 3;
}

-(BOOL)isStale{
    NSInteger hours = [self hoursBetween:self and:[NSDate date]];
    return hours > 6;
}

-(BOOL)isAncient{
    NSInteger hours = [self hoursBetween:self and:[NSDate date]];
    return hours > 36;
}

- (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSCalendarUnitHour;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (firstDate == nil) {
        firstDate = [NSDate date];
    }
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]+1;
}


@end

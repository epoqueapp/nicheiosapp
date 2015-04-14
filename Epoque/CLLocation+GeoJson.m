//
//  CLLocation+GeoJson.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "CLLocation+GeoJson.h"

@implementation CLLocation (GeoJson)

-(NSArray *)toGeoJson{
    return @[@(self.coordinate.longitude), @(self.coordinate.latitude)];
}

-(NSArray *)toGeoJsonWthObscurity:(float)obscurity{
    
    float randomLatDiv = [self randomFloat:-obscurity maxValue:obscurity] / 500;
    float randomLongDiv = [self randomFloat:-obscurity maxValue:obscurity] / 500;
    
    return @[@(self.coordinate.longitude + randomLongDiv), @(self.coordinate.latitude + randomLatDiv)];
}

-(float)randomFloat:(float)minValue maxValue:(float)maxValue{
    return ((float)arc4random() / ARC4RANDOM_MAX * (maxValue - minValue)) + minValue;
}

@end

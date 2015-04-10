//
//  CLLocation+GeoJson.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (GeoJson)

-(NSArray *)toGeoJson;
-(NSArray *)toGeoJsonWthObscurity:(float)obscurity;

@end

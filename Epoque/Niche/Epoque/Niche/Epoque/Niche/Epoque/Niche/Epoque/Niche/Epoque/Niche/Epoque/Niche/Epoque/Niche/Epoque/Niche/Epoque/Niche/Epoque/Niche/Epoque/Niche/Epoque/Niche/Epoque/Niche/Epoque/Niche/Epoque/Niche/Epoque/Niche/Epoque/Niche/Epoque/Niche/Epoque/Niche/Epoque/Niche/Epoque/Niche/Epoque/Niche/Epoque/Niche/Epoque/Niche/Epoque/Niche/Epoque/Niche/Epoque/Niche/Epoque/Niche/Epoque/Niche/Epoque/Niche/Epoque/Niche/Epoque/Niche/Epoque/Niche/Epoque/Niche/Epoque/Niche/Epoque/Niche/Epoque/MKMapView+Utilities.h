//
//  MKMapView+Utilities.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Utilities)

-(void)zoomToLocation:(CLLocationCoordinate2D)coord withSpan:(float)span;

@end

//
//  MKMapView+Utilities.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "MKMapView+Utilities.h"

@implementation MKMapView (Utilities)

-(void)zoomToLocation:(CLLocationCoordinate2D)coord withSpan:(float)span{
    MKCoordinateRegion mapRegion;
    mapRegion.center = coord;
    mapRegion.span = MKCoordinateSpanMake(span, span);
    [self setRegion:mapRegion animated: NO];
}

@end

//
//  BlurbAnnotationView.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BlurbAnnotation.h"
static NSString *const kNCBlurbAnnotationReuseIdentifier = @"kNCBlurbAnnotationReuseIdentifier";

@interface BlurbAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView *spriteImageView;
@property (nonatomic, strong) BlurbAnnotation *blurbAnnotation;

@end

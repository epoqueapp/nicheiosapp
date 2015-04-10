//
//  UserAnnotationView.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import "UserAnnotation.h"
@interface UserAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView *spriteImageView;
@property (nonatomic, strong) UserAnnotation *userAnnotation;
@property (nonatomic, strong) NSMutableArray *shoutRings;
@property (nonatomic, strong) UIImageView *shoutBubbleImageView;
@property (nonatomic, strong) UIImageView *mediaBubbleImageView;
@property (nonatomic, strong) MarqueeLabel *shoutLabel;
@property (nonatomic, strong) UIImageView *plateImageView;

-(void)animateRings;
-(void)animateRingsWithColor:(UIColor *)color;

@end

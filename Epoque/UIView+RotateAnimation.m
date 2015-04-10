//
//  UIView+RotateAnimation.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UIView+RotateAnimation.h"

@implementation UIView (RotateAnimation)

- (void) runSpinAnimationWithDuration:(CGFloat)duration isClockwise:(BOOL)isClockwise;
{
    NSInteger direction = isClockwise ? 1: -1;
    
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/ (180*direction))];
    fullRotation.duration = duration;
    fullRotation.repeatCount = INFINITY;
    [self.layer addAnimation:fullRotation forKey:@"360"];
}

@end

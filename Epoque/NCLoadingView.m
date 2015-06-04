//
//  NCLoadingView.m
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLoadingView.h"

@implementation NCLoadingView

-(void)awakeFromNib{
    CALayer *layer = self.clockHolderView.layer;
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = -1.0 / 1000;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 45.0f * M_PI / 180.0f, 0.5f, 1.0f, 0.0f);
    layer.transform = rotationAndPerspectiveTransform;
    
    self.loadingLabel.strokeColor = [UIColor blackColor];
    self.loadingLabel.strokeSize = 2.0f;
    
    
    
}



-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self.hourHandImageView runSpinAnimationWithDuration:2 isClockwise:YES];
    [self.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self.hourHandImageView runSpinAnimationWithDuration:2 isClockwise:YES];
    [self.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
}

+(void)showInView:(UIView *)view{
    [self hideAllFromView:view];
    [self showInView:view withTitleText:@"Loading..."];
}

+(void)showInView:(UIView *)view withTitleText:(NSString *)titleText{
    NCLoadingView *loadingView = (NCLoadingView *)[[[NSBundle mainBundle] loadNibNamed:@"NCLoadingView" owner:self options:nil] firstObject];
    
    loadingView.frame = CGRectMake(0, 0, view.frame.size.width, 130);
    loadingView.alpha = 0;
    [view addSubview:loadingView];
    
    
    
    loadingView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height /2);
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = loadingView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (__bridge id)UIColor.clearColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.clearColor.CGColor,
                       nil];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:1.25/16],
                          [NSNumber numberWithFloat:14.25/16],
                          [NSNumber numberWithFloat:1],
                          nil];
    
    loadingView.layer.mask = gradient;
    
    
    [loadingView.hourHandImageView runSpinAnimationWithDuration:2 isClockwise:YES];
    [loadingView.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
    loadingView.loadingLabel.text = titleText;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        loadingView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    
    loadingView.loadingLabel.frame = CGRectOffset(loadingView.loadingLabel.frame, -20, 0);
    loadingView.clockHolderView.frame = CGRectOffset(loadingView.loadingLabel.frame, 20, 0);
    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        loadingView.loadingLabel.frame = CGRectOffset(loadingView.loadingLabel.frame, 20, 0);
        loadingView.clockHolderView.frame = CGRectOffset(loadingView.loadingLabel.frame, -20, 0);
    } completion:nil];
    

    
    
}

+(void)hideAllFromView:(UIView *)view{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[NCLoadingView class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                subview.alpha = 0;
            } completion:^(BOOL finished) {
                [subview removeFromSuperview];
            }];
        }
    }
}

@end

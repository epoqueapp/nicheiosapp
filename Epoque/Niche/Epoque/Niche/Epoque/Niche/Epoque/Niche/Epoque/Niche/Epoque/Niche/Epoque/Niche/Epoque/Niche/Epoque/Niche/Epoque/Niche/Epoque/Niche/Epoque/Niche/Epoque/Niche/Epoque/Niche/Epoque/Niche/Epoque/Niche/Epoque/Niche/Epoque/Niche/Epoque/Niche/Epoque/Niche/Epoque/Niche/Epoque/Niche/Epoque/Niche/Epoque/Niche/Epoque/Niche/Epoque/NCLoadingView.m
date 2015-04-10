//
//  NCLoadingView.m
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLoadingView.h"

@implementation NCLoadingView

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self.hourHandImageView runSpinAnimationWithDuration:4 isClockwise:YES];
    [self.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
    [self.hourHandImageView runSpinAnimationWithDuration:4 isClockwise:YES];
    [self.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
}

+(void)showInView:(UIView *)view{
    [self hideAllFromView:view];
    [self showInView:view withTitleText:@"Loading..."];
}

+(void)showInView:(UIView *)view withTitleText:(NSString *)titleText{
    NCLoadingView *loadingView = (NCLoadingView *)[[[NSBundle mainBundle] loadNibNamed:@"NCLoadingView" owner:self options:nil] firstObject];
    loadingView.alpha = 0;
    [view addSubview:loadingView];
    loadingView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height /2);
    [loadingView.hourHandImageView runSpinAnimationWithDuration:4 isClockwise:YES];
    [loadingView.minuteHandImageView runSpinAnimationWithDuration:3 isClockwise:NO];
    loadingView.layer.cornerRadius = 4.0f;
    loadingView.loadingLabel.text = titleText;
    [UIView animateWithDuration:0.10 animations:^{
        loadingView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

+(void)hideAllFromView:(UIView *)view{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[NCLoadingView class]]) {
            [UIView animateWithDuration:0.10 animations:^{
                subview.alpha = 0;
            } completion:^(BOOL finished) {
                [subview removeFromSuperview];
            }];
        }
    }
}

@end

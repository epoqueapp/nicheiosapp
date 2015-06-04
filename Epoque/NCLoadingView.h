//
//  NCLoadingView.h
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THLabel/THLabel.h>
@interface NCLoadingView : UIView

@property (nonatomic ,weak) IBOutlet UIImageView *hourHandImageView;
@property (nonatomic, weak) IBOutlet UIImageView *minuteHandImageView;
@property (nonatomic, weak) IBOutlet UIImageView *clockImageView;
@property (nonatomic, weak) IBOutlet UIView *clockHolderView;
@property (nonatomic, weak) IBOutlet THLabel *loadingLabel;

+(void)showInView:(UIView *)view;
+(void)showInView:(UIView *)view withTitleText:(NSString *)titleText;
+(void)hideAllFromView:(UIView *)view;

@end

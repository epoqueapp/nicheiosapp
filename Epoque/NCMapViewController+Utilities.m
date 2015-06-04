//
//  NCMapViewController+Utilities.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/26/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+Utilities.h"

@implementation NCMapViewController (Utilities)

-(void)setChatPreviewViewWithUserId:(NSString *)userId spriteUrl:(NSString *)spriteUrl name:(NSString *)name messageText:(NSString *)messageText messageImageUrl:(NSString *)messageImageUrl timestamp:(NSDate *)timestamp backgroundColor:(UIColor *)backgroundColor{
    
    
    self.chatPreviewUserId = [userId copy];
    [self.chatPreviewSpriteImageView sd_setImageWithURL:[NSURL URLWithString:spriteUrl]];
    self.chatPreviewNameLabel.text = name;
    
    if (messageImageUrl.length > 0) {
        self.chatPreviewMessageLabel.text = [[NSString randomImageEmoji] stringByAppendingString:@" attached an image"];
    }else{
        self.chatPreviewMessageLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString speechBubbleEmoji], messageText];
    }
    self.chatPreviewTimeLabel.text = [timestamp tableViewCellTimeString];
    
    self.chatPreviewView.backgroundColor = backgroundColor;
}

@end

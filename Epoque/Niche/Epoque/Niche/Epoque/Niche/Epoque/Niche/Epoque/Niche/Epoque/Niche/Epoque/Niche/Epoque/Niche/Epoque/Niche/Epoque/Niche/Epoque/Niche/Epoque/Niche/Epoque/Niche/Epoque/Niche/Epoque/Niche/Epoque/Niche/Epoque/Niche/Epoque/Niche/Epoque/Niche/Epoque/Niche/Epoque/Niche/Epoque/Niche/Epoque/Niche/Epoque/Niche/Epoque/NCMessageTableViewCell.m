//
//  NCMessageTableViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMessageTableViewCell.h"

@implementation NCMessageTableViewCell

-(void)awakeFromNib{
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    self.spriteImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textMessageLabel.text = @"";
    self.textMessageLabel.textColor = [UIColor whiteColor];
    self.textMessageLabel.verticalAlignment = VerticalAlignmentTop;
    self.textMessageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.textMessageLabel.linkAttributes = @{
                                             NSForegroundColorAttributeName: [UIColor colorWithRed:127.0/255.0 green:211.0/255.0 blue:92.0/255.0 alpha:1.0],
                                             NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
}

@end

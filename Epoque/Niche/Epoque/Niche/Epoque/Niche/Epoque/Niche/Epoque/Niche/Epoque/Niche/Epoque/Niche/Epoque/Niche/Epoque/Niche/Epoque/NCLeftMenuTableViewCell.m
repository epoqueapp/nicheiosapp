//
//  NCLeftMenuTableViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLeftMenuTableViewCell.h"

@implementation NCLeftMenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.menuItemLabel.strokeColor = [UIColor blackColor];
    self.menuItemLabel.strokeSize = 1.0f;
    self.menuItemLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

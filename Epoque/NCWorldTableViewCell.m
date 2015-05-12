//
//  NCWorldTableViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldTableViewCell.h"

@implementation NCWorldTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.emblemImageView.layer.cornerRadius = 3.0f;
    self.emblemImageView.layer.masksToBounds = YES;
    self.emblemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emblemImageView.layer.borderWidth = 1.0;
    
    self.emblemImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.detailLabel.userInteractionEnabled = NO;
    self.emblemImageView.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.memberCountLabel.strokeColor = [UIColor blackColor];
    self.memberCountLabel.strokeSize = 0.25;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  NCImageMessageTableViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCImageMessageTableViewCell.h"

@implementation NCImageMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userImageView.layer.magnificationFilter = kCAFilterNearest;
    
    self.messageImageView.layer.cornerRadius = 3.0f;
    self.messageImageView.layer.masksToBounds = YES;
    self.messageImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.messageImageView.backgroundColor = [UIColor blackColor];
    
    self.nameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:12.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  NCConversationTableViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCConversationTableViewCell.h"

@implementation NCConversationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    self.summaryTextView.font = [UIFont fontWithName:kTrocchiFontName size:12.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  NCUserTableViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUserTableViewCell.h"

@implementation NCUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

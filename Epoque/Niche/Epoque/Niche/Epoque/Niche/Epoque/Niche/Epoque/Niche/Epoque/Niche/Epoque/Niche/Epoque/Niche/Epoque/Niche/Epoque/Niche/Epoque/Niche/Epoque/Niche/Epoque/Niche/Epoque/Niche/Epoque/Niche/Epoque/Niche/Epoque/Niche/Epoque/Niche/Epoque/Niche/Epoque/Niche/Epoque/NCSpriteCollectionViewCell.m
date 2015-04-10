//
//  NCSpriteCollectionViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCSpriteCollectionViewCell.h"

@implementation NCSpriteCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
}

@end

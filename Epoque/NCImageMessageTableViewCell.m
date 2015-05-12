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
    self.userImageView.layer.magnificationFilter = kCAFilterNearest;
    self.messageImageView.layer.cornerRadius = 3.0f;
    self.messageImageView.layer.masksToBounds = YES;
    self.messageImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.messageImageView.backgroundColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:10.0];
    self.heartImageView.layer.magnificationFilter = kCAFilterNearest;
    
    self.likeCountLabel.textColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tappedHeartGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedHeartImageView:)];
    self.heartImageView.userInteractionEnabled = YES;
    [self.heartImageView addGestureRecognizer:tappedHeartGesture];
    
    UITapGestureRecognizer *tappedSpriteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedSpriteImageView:)];
    self.userImageView.userInteractionEnabled = YES;
    [self.userImageView addGestureRecognizer:tappedSpriteGesture];
    
    UITapGestureRecognizer *tappedNameGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedNameLabel:)];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:tappedNameGesture];
}

-(void)tappedNameLabel:(id)sender{
    [self.messageNameLabelDelegate tappedNameLabel:self.indexPath];
}


-(void)tappedHeartImageView:(id)sender{
    [self.heartDelegate tappedHeart:self.indexPath];
}

-(void)tappedSpriteImageView:(id)sender{
    [self.tableSpriteDelegate tappedSprite:self.indexPath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

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
    
    self.userNameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:10.0];
    self.heartImageView.layer.magnificationFilter = kCAFilterNearest;
    self.likeCountLabel.textColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tappedHeartGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedHeartImageView:)];
    self.heartImageView.userInteractionEnabled = YES;
    [self.heartImageView addGestureRecognizer:tappedHeartGesture];
    
    UITapGestureRecognizer *tappedSpriteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedSpriteImageView:)];
    self.spriteImageView.userInteractionEnabled = YES;
    [self.spriteImageView addGestureRecognizer:tappedSpriteGesture];
    
    UITapGestureRecognizer *tappedNameGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedNameLabel:)];
    self.userNameLabel.userInteractionEnabled = YES;
    [self.userNameLabel addGestureRecognizer:tappedNameGesture];
}

-(void)tappedNameLabel:(id)sender{
    [self.messageNameLabelDelegate tappedNameLabel:self.indexPath];
}

-(void)tappedSpriteImageView:(id)sender{
    [self.tableSpriteDelegate tappedSprite:self.indexPath];
}

-(void)tappedHeartImageView:(id)sender{
    [self.heartDelegate tappedHeart:self.indexPath];
}

@end

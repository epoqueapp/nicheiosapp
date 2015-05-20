//
//  NCMessageTableViewCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLabel.h"
#import "NCHeartDelegate.h"
#import "NCTableSpriteDelegate.h"
#import "MessageModel.h"

#define kAvatarSize 32.0
#define kMinimumHeight 90.0


@protocol NCMessageTableViewCellDelegate <NSObject>

@optional
-(void)tappedSpriteImageView:(NSIndexPath *)indexPath;
-(void)tappedUserNameLabel:(NSIndexPath *)indexPath;

@end


@interface NCMessageTableViewCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImageView *spriteImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) TTTAttributedLabel *textMessageLabel;
@property (nonatomic, strong) UIImageView *attachmentImageView;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UIImageView *heartImageView;

@property (nonatomic, assign) id<NCMessageTableViewCellDelegate> delegate;

-(void)setMessageModel:(MessageModel *)messageModel;

@end

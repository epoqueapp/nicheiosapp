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
#import "NCMessageNameLabelDelegate.h"

@interface NCMessageTableViewCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *textMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *likeCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *heartImageView;

@property (nonatomic, assign) id<NCHeartDelegate> heartDelegate;
@property (nonatomic, assign) id<NCTableSpriteDelegate> tableSpriteDelegate;
@property (nonatomic, assign) id<NCMessageNameLabelDelegate> messageNameLabelDelegate;

@end

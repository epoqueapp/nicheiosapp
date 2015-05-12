//
//  NCImageMessageTableViewCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCHeartDelegate.h"
#import "NCTableSpriteDelegate.h"
#import "NCMessageNameLabelDelegate.h"
@interface NCImageMessageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *messageImageView;
@property (nonatomic, weak) IBOutlet UIImageView *heartImageView;
@property (nonatomic, weak) IBOutlet UILabel *likeCountLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id<NCHeartDelegate> heartDelegate;
@property (nonatomic, assign) id<NCTableSpriteDelegate> tableSpriteDelegate;
@property (nonatomic, assign) id<NCMessageNameLabelDelegate> messageNameLabelDelegate;
@end

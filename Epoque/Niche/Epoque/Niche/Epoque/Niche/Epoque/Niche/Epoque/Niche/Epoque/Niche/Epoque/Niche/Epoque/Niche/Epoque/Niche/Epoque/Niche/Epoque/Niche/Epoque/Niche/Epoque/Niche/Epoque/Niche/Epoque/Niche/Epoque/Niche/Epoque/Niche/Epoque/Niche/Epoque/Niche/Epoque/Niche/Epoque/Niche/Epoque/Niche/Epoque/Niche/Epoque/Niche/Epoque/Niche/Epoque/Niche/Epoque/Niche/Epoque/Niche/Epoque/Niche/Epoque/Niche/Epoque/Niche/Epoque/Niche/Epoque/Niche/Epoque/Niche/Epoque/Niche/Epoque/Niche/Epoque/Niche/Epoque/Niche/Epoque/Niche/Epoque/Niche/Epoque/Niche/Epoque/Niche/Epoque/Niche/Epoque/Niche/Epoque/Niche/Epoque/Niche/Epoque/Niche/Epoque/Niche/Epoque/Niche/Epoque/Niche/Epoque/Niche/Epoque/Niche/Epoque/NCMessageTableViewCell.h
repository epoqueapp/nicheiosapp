//
//  NCMessageTableViewCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLabel.h"
#define kAvatarSize 30.0
#define kMinimumHeight 70.0

@interface NCMessageTableViewCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *textMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;


@end

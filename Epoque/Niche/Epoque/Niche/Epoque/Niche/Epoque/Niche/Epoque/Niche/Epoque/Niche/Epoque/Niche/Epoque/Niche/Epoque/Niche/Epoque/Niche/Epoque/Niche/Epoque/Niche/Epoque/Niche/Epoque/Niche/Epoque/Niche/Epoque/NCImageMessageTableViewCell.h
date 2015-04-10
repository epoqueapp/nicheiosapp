//
//  NCImageMessageTableViewCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCImageMessageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *messageImageView;

@end

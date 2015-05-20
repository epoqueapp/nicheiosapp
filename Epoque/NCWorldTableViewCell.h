//
//  NCWorldTableViewCell.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
@interface NCWorldTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *worldImageView;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *starImageView;
@property (nonatomic, weak) IBOutlet UIImageView *keyImageView;

@property (nonatomic, weak) IBOutlet UILabel *badgeLabel;

@property (nonatomic, copy) NSString *worldId;

@end

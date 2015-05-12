//
//  NCWorldTableViewCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THLabel.h>
@interface NCWorldTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *emblemImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *privateImageView;
@property (nonatomic, weak) IBOutlet THLabel *memberCountLabel;
@end

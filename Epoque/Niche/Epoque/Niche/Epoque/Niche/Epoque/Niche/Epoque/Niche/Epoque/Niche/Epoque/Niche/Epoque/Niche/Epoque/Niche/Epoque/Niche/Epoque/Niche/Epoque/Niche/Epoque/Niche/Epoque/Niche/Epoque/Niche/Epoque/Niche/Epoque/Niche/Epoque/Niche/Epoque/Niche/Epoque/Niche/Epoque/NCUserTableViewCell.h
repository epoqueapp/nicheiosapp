//
//  NCUserTableViewCell.h
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCUserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *aboutLabel;
@property (nonatomic, weak) IBOutlet UILabel *roleLabel;
@end

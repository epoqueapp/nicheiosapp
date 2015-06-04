//
//  NCWorldTableViewCell.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldModel.h"
@interface NCWorldTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *worldImageView;
@property (nonatomic, weak) IBOutlet UILabel *worldNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *firstIconImageView;
@property (nonatomic, weak) IBOutlet UIImageView *secondIconImageView;
@property (nonatomic, weak) IBOutlet UIImageView *thirdIconImageView;

-(void)setWorldModel:(WorldModel *)worldModel;


@end

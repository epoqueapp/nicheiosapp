//
//  NCWorldCollectionViewCell.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/15/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THLabel/THLabel.h>
@interface NCWorldCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, weak) IBOutlet UIImageView *keyImageView;
@property (nonatomic, weak) IBOutlet UIImageView *starImageView;
@property (nonatomic, weak) IBOutlet UIImageView *worldImageView;
@property (nonatomic, weak) IBOutlet THLabel *worldNameLabel;
@property (nonatomic, weak) IBOutlet THLabel *notificationLabel;

@end

//
//  NCWorldDetailViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldModel.h"
#import "NCUsersTableViewController.h"

@interface NCWorldDetailViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *emblemImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *detailTextView;

@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *notificationButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *refreshPasscodeButton;

@property (nonatomic, weak) IBOutlet UILabel *pinLabel;
@property (nonatomic, weak) IBOutlet UIImageView *keyImageView;

@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL isPushOn;

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, strong) WorldModel *worldModel;
@end

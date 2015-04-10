//
//  NCWorldDetailViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldModel.h"
@interface NCWorldDetailViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *emblemImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *detailTextView;
@property (nonatomic, weak) IBOutlet UIButton *requestToJoinButton;
@property (nonatomic, weak) IBOutlet UIButton *inviteUsersButton;
@property (nonatomic, weak) IBOutlet UIButton *toggleNotificationButton;

@property (nonatomic, weak) IBOutlet UILabel *worldTypeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *worldTypeImageView;

@property (nonatomic, assign) BOOL isPushOn;

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, strong) WorldModel *worldModel;
@end

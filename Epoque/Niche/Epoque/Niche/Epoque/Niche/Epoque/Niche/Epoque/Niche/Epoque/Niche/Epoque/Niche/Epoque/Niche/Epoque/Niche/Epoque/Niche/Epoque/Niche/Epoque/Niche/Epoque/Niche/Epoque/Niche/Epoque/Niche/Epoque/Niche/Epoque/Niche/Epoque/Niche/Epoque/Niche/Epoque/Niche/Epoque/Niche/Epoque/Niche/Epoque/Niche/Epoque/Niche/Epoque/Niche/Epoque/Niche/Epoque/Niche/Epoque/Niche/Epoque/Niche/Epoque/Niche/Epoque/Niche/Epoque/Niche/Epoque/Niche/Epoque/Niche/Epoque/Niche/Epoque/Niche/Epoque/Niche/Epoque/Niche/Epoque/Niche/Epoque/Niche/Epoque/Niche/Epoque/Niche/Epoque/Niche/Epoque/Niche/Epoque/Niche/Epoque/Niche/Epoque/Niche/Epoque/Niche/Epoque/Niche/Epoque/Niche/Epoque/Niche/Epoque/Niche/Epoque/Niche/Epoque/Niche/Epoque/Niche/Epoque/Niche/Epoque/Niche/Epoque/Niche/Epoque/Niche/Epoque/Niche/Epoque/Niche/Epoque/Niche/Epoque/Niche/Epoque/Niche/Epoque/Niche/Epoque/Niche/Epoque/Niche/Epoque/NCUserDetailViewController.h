//
//  NCUserDetailViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCUserDetailViewController : UIViewController

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAbout;
@property (nonatomic, copy) NSString *spriteImageUrl;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *messageImageUrl;
@property (nonatomic, copy) NSDate *timestamp;


@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *aboutTextView;
@property (nonatomic, weak) IBOutlet UITextView *messageTextView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *messageImageView;
@property (nonatomic, weak) IBOutlet UIButton *privateMessageButton;


@end

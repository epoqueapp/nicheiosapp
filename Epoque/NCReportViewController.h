//
//  NCReportViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/13/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
@interface NCReportViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, copy) NSString *regardingUserId;
@property (nonatomic, copy) NSString *regardingUserName;
@property (nonatomic, copy) NSString *regardingUserSpriteUrl;

@end

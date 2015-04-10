//
//  NCFacebookLoginViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "NCSpritesViewController.h"
@interface NCFacebookLoginViewController : UIViewController <NCSpritesViewControllerDelegate, UIActionSheetDelegate, FBSDKLoginButtonDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, copy) NSString *spriteUrl;

@end

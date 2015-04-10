//
//  NCAboutViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCAboutViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *privacyPolicyButton;
@property (nonatomic, weak) IBOutlet UIButton *termsOfServiceButton;
@property (nonatomic, weak) IBOutlet UIButton *visitWebsiteButton;
@property (nonatomic, weak) IBOutlet UILabel *versionAndBuildLabel;

@end

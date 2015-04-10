//
//  NCLoginViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
@interface NCLoginViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) FXFormController *formController;
@end

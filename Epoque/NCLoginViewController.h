//
//  NCLoginViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import "NCLoginForm.h"
@interface NCLoginViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;

@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;

@end

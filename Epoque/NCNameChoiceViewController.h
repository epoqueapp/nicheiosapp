//
//  NCNameChoiceViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/14/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import "NCSpritesViewController.h"
@interface NCNameChoiceViewController : UIViewController <NCSpritesViewControllerDelegate, FXFormControllerDelegate>

@property (nonatomic, copy) NSString *spriteUrl;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@end

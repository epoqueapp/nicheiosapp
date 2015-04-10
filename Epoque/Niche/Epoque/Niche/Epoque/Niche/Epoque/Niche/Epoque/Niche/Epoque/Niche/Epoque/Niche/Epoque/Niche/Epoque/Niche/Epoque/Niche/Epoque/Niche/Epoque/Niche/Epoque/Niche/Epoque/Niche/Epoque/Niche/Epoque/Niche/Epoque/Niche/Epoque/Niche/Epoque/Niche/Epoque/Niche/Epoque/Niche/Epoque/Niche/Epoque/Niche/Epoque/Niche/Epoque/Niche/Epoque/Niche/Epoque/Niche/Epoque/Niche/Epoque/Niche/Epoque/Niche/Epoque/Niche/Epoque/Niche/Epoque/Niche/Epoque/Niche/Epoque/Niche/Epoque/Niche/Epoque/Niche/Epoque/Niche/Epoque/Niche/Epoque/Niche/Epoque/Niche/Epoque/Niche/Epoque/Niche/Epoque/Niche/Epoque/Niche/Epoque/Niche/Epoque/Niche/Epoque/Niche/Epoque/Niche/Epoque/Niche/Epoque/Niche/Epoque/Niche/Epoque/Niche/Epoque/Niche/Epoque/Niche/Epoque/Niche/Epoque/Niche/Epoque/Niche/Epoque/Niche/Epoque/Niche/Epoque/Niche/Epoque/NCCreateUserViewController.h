//
//  NCCreateUserViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms.h>
#import "NCSpritesViewController.h"
@interface NCCreateUserViewController : UIViewController <FXFormControllerDelegate, NCSpritesViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;


@property (nonatomic, copy) NSString *spriteUrl;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@end

//
//  NCEditBlurbViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import "NCBlurbForm.h"

@interface NCEditBlurbViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, copy) NSString *blurbId;
@property (nonatomic, strong) FXFormController *formController;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

//
//  NCMyCharacterViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import "NCSpritesViewController.h"
@interface NCMyCharacterViewController : UIViewController <FXFormControllerDelegate, NCSpritesViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;

@end

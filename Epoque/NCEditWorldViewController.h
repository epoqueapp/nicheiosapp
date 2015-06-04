//
//  NCEditWorldViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/11/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import "NCRefreshDelegate.h"
#import "WorldModel.h"

@interface NCEditWorldViewController : UIViewController <FXFormControllerDelegate, NCRefreshDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;
@property (nonatomic, assign) id<NCRefreshDelegate> delegate;
@end

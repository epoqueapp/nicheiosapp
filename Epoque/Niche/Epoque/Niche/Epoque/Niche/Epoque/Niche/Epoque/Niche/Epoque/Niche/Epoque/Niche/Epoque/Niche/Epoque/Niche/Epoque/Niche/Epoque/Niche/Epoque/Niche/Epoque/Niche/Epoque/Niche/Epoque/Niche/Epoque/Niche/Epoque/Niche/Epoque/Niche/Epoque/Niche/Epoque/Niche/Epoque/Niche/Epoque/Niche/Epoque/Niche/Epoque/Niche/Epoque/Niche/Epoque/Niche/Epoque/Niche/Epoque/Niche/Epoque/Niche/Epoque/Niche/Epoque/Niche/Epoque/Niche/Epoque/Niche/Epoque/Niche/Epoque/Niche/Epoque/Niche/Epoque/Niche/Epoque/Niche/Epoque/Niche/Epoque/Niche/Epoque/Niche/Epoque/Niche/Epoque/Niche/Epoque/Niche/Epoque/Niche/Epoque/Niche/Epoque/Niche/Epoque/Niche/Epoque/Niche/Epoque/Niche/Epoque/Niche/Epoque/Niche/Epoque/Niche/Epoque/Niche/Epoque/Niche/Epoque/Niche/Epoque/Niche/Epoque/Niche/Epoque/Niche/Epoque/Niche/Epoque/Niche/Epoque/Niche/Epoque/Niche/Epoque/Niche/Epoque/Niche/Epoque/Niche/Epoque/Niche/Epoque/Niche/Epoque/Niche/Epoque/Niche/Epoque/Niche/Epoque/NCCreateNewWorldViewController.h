//
//  NCCreateNewWorldViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXForms/FXForms.h>
#import <WEPopover/WEPopoverController.h>
#import <ColorViewController.h>
#import "NCCreateWorldForm.h"
#import "NCRefreshDelegate.h"
typedef enum ColorElementType : NSUInteger {
    kBackground,
    kForeground
} ColorElementType;



@interface NCCreateNewWorldViewController : UIViewController <FXFormControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ColorViewControllerDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FXFormController *formController;
@property (nonatomic, strong) WEPopoverController *wePopoverController;
@property (nonatomic, assign) ColorElementType colorElementType;

@property (nonatomic, assign) id<NCRefreshDelegate> delegate;


@end

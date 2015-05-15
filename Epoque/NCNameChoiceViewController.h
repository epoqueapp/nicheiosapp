//
//  NCNameChoiceViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/14/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NCSpritesViewController.h"
@interface NCNameChoiceViewController : UIViewController <NCSpritesViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, copy) NSString *spriteUrl;

@property (nonatomic, weak) IBOutlet UIImageView *spriteImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;


@end

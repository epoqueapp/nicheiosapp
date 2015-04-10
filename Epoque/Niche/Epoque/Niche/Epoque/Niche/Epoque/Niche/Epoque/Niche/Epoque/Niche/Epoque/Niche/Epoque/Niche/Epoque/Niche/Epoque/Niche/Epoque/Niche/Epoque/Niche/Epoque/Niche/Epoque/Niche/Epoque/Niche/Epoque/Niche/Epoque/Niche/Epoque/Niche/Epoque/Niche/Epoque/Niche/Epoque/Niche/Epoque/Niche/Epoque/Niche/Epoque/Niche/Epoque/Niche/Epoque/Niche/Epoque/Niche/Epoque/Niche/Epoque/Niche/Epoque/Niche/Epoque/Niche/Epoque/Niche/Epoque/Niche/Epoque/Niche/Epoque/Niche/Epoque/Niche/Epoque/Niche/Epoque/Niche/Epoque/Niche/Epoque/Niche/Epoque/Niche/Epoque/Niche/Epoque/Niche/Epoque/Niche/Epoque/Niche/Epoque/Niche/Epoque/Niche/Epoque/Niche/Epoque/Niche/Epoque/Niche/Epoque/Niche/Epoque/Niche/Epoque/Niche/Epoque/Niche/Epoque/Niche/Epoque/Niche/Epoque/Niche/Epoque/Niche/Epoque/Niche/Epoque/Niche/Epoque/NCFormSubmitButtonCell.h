//
//  NCFormSubmitButtonCell.h
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "FXForms.h"

@interface NCFormSubmitButtonCell : FXFormBaseCell

@property (nonatomic, weak) IBOutlet UIButton *button;

-(IBAction)buttonDidTap:(id)sender;

@end

//
//  NCFormSubmitButtonCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFormSubmitButtonCell.h"

@implementation NCFormSubmitButtonCell

-(void)awakeFromNib{
    self.button.layer.cornerRadius = 3.0f;
    self.button.layer.masksToBounds = YES;
    self.button.backgroundColor = [UIColor blackColor];
    self.button.layer.borderColor = [UIColor whiteColor].CGColor;
    self.button.layer.borderWidth = 0.75f;
    self.button.layer.shadowOffset = CGSizeMake(2.5f,2.5f);
    self.button.layer.shadowRadius = 1.5f;
    self.button.layer.shadowOpacity = 0.9f;
    self.button.layer.shadowColor = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
    self.button.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.button.bounds].CGPath;
}

-(void)setUp{
    [super setUp];
    
}

-(IBAction)buttonDidTap:(id)sender{
    if(self.field.action)
    {
        self.field.action(self);
    }
}

-(void)update{
    [super update];
    self.button.layer.cornerRadius = 3.0f;
    self.button.layer.masksToBounds = YES;
    NSString *title = self.field.title;
    if (title == nil) {
        title = @"Submit";
    }
    [self.button setTitle:title forState:UIControlStateNormal];
}

-(void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller{
    [tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    if(self.field.action)
    {
        self.field.action(self);
    }
}


@end

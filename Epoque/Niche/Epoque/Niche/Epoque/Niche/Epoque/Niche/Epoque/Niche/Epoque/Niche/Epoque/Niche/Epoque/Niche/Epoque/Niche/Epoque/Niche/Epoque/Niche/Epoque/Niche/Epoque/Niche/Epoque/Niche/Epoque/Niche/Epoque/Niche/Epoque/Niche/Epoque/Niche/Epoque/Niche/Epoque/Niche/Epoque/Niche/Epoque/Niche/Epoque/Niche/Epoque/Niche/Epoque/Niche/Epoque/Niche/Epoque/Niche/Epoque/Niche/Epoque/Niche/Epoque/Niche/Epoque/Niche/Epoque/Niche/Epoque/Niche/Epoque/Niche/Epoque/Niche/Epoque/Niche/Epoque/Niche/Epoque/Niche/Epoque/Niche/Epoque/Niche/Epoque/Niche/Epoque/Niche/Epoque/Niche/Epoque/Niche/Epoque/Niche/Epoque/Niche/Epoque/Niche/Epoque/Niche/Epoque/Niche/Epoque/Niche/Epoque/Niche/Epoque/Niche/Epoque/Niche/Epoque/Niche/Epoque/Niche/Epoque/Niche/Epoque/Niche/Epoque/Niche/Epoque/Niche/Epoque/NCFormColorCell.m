//
//  NCFormColorCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFormColorCell.h"

@implementation NCFormColorCell

-(void)awakeFromNib{
    self.colorView.layer.cornerRadius = 6.0f;
    self.colorView.layer.masksToBounds = YES;
    self.colorView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.colorView.layer.borderWidth = 1.0f;
    [super awakeFromNib];
}

-(void)setUp{
    [super setUp];
}

-(void)update{
    [super update];
    self.colorView.backgroundColor = self.field.value;
    self.formFieldTextLabel.text = self.field.title;
}

-(void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller{
    if (self.field.action) {
        self.field.action(self);
    }
}

@end

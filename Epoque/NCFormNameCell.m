//
//  NCFormNameCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/26/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFormNameCell.h"

@implementation NCFormNameCell

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)setUp{
    [super setUp];
}

-(void)update{
    [super update];
}

-(void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller{
    if (self.field.action) {
        self.field.action(self);
    }
}

@end

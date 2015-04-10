//
//  NCFormSpriteCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFormSpriteCell.h"

@implementation NCFormSpriteCell

-(void)awakeFromNib{
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
}

-(void)setUp{
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
}

-(void)update{
    NSString *spriteUrl = self.field.value;
    if (spriteUrl) {
        [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:spriteUrl]];
    }
}

-(void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller{
    [tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    if(self.field.action)
    {
        self.field.action(self);
    }
}


@end

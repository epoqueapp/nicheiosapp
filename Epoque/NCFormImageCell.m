//
//  NCFormImageCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFormImageCell.h"

@implementation NCFormImageCell

-(void)update{
    [super update];
    [self setEmblemImageViewWithImage:self.field.value];
}

-(void)setUp{
    [super setUp];
    [self setEmblemImageViewWithImage:self.field.value];
    self.emblemImageView.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)setEmblemImageViewWithImage:(UIImage *)image{
    if (image == nil) {
        self.emblemImageView.image = [UIImage imageNamed:@"image_placeholder"];
        self.field.value = [UIImage imageNamed:@"image_placeholder"];
    }else{
        self.emblemImageView.image = image;
    }
    self.emblemImageView.layer.cornerRadius = 3.0f;
    self.emblemImageView.layer.masksToBounds = YES;
}

-(void)didSelectWithTableView:(UITableView *)tableView controller:(UIViewController *)controller{
    [tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    if(self.field.action){
        self.field.action(self);
    }
}


@end

//
//  NCShareWorldView.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/16/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCShareWorldView.h"

@implementation NCShareWorldView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.linkLabel.strokeColor = [UIColor whiteColor];
    self.linkLabel.strokeSize = 1.0;
    
    self.worldNameLabel.strokeColor = [UIColor whiteColor];
    self.worldNameLabel.strokeSize = 1.0;
    
    self.pinLabel.strokeColor = [UIColor whiteColor];
    self.pinLabel.strokeSize = 1.0;
    self.pinLabel.hidden = YES;
    
    self.secretLabel.strokeColor = [UIColor whiteColor];
    self.secretLabel.strokeSize = 1.0;
    self.secretLabel.hidden = YES;
}

-(void)setPINWithString:(NSString *)pinString{
    self.pinLabel.hidden = NO;
    self.secretLabel.hidden = NO;
    self.pinLabel.text = [pinString copy];
}

+(NCShareWorldView *)generateView{
    NCShareWorldView *loadingView = (NCShareWorldView *)[[[NSBundle mainBundle] loadNibNamed:@"NCShareWorldView" owner:self options:nil] firstObject];
    return loadingView;
}

-(UIImage *)toImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end

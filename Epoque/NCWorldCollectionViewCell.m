//
//  NCWorldCollectionViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/15/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldCollectionViewCell.h"

@implementation NCWorldCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.worldNameLabel.strokeColor = [UIColor blackColor];
    self.worldNameLabel.strokeSize = 1.25;
    self.worldNameLabel.textColor = [UIColor whiteColor];
    self.worldNameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:12.0];
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    
    
    self.keyImageView.layer.shadowColor = [UIColor purpleColor].CGColor;
    self.keyImageView.layer.shadowOffset = CGSizeMake(0, 1);
    self.keyImageView.layer.shadowOpacity = 1;
    self.keyImageView.layer.shadowRadius = 1.0;
    self.keyImageView.clipsToBounds = NO;
}

@end

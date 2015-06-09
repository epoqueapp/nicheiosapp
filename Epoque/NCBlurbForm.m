//
//  NCBlurbForm.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCBlurbForm.h"
#import "NCFormSpriteCell.h"
@implementation NCBlurbForm

-(NSDictionary *)spriteUrlField{
    return @{
             FXFormFieldCell: [NCFormSpriteCell class],
             FXFormFieldAction: @"spriteDidTap",
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)nameField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textField.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)detailField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textView.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textView.textColor": [UIColor whiteColor],
             FXFormFieldType: FXFormFieldTypeLongText,
             @"backgroundColor": [UIColor clearColor]
             };
}

@end

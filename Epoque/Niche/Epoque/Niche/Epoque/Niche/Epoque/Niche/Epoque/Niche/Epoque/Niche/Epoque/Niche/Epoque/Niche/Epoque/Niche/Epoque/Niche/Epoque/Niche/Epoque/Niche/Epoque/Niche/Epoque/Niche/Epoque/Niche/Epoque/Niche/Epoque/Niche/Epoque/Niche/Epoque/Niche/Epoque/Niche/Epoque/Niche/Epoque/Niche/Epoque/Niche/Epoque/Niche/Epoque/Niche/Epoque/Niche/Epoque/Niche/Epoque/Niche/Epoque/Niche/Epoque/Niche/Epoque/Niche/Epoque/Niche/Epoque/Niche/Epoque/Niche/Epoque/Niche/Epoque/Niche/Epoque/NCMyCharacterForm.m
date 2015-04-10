//
//  NCMyCharacterForm.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMyCharacterForm.h"
#import "NCFormSpriteCell.h"
#import "NCFormSubmitButtonCell.h"
@implementation NCMyCharacterForm

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
             @"textField.textColor": [UIColor whiteColor],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)aboutField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textView.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textView.textColor": [UIColor whiteColor],
             FXFormFieldType: FXFormFieldTypeLongText,
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)obscurityField{
    
    NSMutableArray *arrayOfOptions = [NSMutableArray array];
    for (int i = 0; i < 26; i++) {
        [arrayOfOptions addObject:@(i)];
    }
    
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             FXFormFieldType: FXFormFieldTypeUnsigned,
             FXFormFieldTitle: @"Obscurity *",
             @"textField.textColor": [UIColor whiteColor],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSArray *)extraFields{
    return @[
             @{
                 FXFormFieldTitle: @"Update Character",
                 FXFormFieldCell: [NCFormSubmitButtonCell class],
                 FXFormFieldAction: @"submitButtonDidTap",
                 @"backgroundColor": [UIColor clearColor]
                 }];
}


@end

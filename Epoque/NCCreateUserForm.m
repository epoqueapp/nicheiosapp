//
//  NCCreateUserForm.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateUserForm.h"
#import "NCFormSpriteCell.h"
#import "NCFormSubmitButtonCell.h"
@implementation NCCreateUserForm

-(NSDictionary *)spriteUrlField{
    return @{
             FXFormFieldCell: [NCFormSpriteCell class],
             FXFormFieldAction: @"spriteDidTap",
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)emailField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textField.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)passwordField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textField.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)nameField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textField.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor],
             @"textField.autocorrectionType": @(UITextAutocorrectionTypeNo)
             };
}

-(NSArray *)extraFields{
    return @[
             @{
                 FXFormFieldTitle: @"Create Character",
                 FXFormFieldCell: [NCFormSubmitButtonCell class],
                 FXFormFieldAction: @"submitButtonDidTap",
                 @"backgroundColor": [UIColor clearColor]
                 }];
}

-(BOOL)isValid{
    return ![self isStringIsNilOrEmpty:self.spriteUrl] &&
    ![self isStringIsNilOrEmpty:self.name] &&
    ![self isStringIsNilOrEmpty:self.password] &&
    ![self isStringIsNilOrEmpty:self.email];
}

-(BOOL)isStringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length);
}

@end

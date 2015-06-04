//
//  NCLoginForm.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLoginForm.h"
#import "NCFormSubmitButtonCell.h"
@implementation NCLoginForm

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

-(NSArray *)extraFields{
    return @[
             @{
                 @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
                 @"textLabel.textColor": [UIColor lightGrayColor],
                 FXFormFieldTitle: @"Login",
                 FXFormFieldCell: [NCFormSubmitButtonCell class],
                 FXFormFieldAction: @"submitButtonDidTap",
                 @"backgroundColor": [UIColor clearColor]
                 }];
}

-(BOOL)isStringIsNilOrEmpty:(NSString*)aString {
    return !(aString && aString.length);
}

-(BOOL)isValid{
    return 
    ![self isStringIsNilOrEmpty:self.password] &&
    ![self isStringIsNilOrEmpty:self.email];
}

@end

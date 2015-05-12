//
//  NCEditWorldForm.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/11/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCEditWorldForm.h"
#import "NCFormImageCell.h"
#import "NCFormSubmitButtonCell.h"
#import "NCFormColorCell.h"
@implementation NCEditWorldForm

-(NSDictionary *)emblemImageField{
    return @{
             FXFormFieldTitle: @"Image",
             FXFormFieldCell: [NCFormImageCell class],
             FXFormFieldAction: @"changeImage",
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

-(NSDictionary *)worldDescriptionField{
    return @{
             FXFormFieldTitle: @"Description",
             FXFormFieldType: FXFormFieldTypeLongText,
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textView.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textView.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor]
             };
}


/*-(NSDictionary *)passcodeField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textField.textColor": [UIColor whiteColor],
             @"backgroundColor": [UIColor clearColor]
             };
}*/


-(NSArray *)extraFields{
    return @[
             @{
                 @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
                 @"textLabel.textColor": [UIColor lightGrayColor],
                 FXFormFieldTitle: @"Save World",
                 FXFormFieldCell: [NCFormSubmitButtonCell class],
                 FXFormFieldAction: @"submitButtonDidTap",
                 @"backgroundColor": [UIColor clearColor]
                 }];
}



-(BOOL)isDirty{
    BOOL hasImage = self.emblemImage != nil;
    BOOL hasName = self.name != nil;
    BOOL hasDescription = self.worldDescription != nil;
    return hasDescription || hasImage || hasName;
}

-(BOOL)isValid{
    BOOL hasImage = self.emblemImage != nil;
    BOOL hasName = self.name != nil;
    BOOL hasDescription = self.worldDescription != nil;
    return hasDescription && hasImage && hasName;
}


@end

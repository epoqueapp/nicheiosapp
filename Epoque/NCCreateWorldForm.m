//
//  NCCreateWorldForm.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateWorldForm.h"
#import "NCFormImageCell.h"
#import "NCFormSubmitButtonCell.h"
#import "NCFormColorCell.h"
@implementation NCCreateWorldForm



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
             @"textField.textColor": [UIColor whiteColor],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"backgroundColor": [UIColor clearColor]
             };
}

-(NSDictionary *)worldDescriptionField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"textView.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             @"textView.textColor": [UIColor whiteColor],
             FXFormFieldType: FXFormFieldTypeLongText,
             @"backgroundColor": [UIColor clearColor]
             };
}


-(NSDictionary *)isPrivateField{
    return @{
             FXFormFieldTitle: @"Private?",
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
             @"textLabel.textColor": [UIColor lightGrayColor],
             @"backgroundColor": [UIColor clearColor]
             };
}


-(NSArray *)extraFields{
    return @[
             @{
                 @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:18.0],
                 @"textLabel.textColor": [UIColor lightGrayColor],
                 FXFormFieldTitle: @"Create World",
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

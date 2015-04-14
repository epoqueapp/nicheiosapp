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
             FXFormFieldAction: @"changeImage"
             };
}

-(NSDictionary *)nameField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             };
}

-(NSDictionary *)worldDescriptionField{
    return @{
             FXFormFieldTitle: @"Description",
             FXFormFieldType: FXFormFieldTypeLongText,
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textView.font": [UIFont fontWithName:kTrocchiFontName size:16.0],
             };
}


-(NSDictionary *)isUnlistedField{
    return @{
             FXFormFieldTitle: @"Unlisted?",
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0]
             };
}

-(NSDictionary *)isPrivateField{
    return @{
             FXFormFieldTitle: @"Private?",
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0]
             };
}


-(NSArray *)extraFields{
    return @[
             @{
                 FXFormFieldTitle: @"Create World",
                 FXFormFieldCell: [NCFormSubmitButtonCell class],
                 FXFormFieldAction: @"submitButtonDidTap"
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
    return hasDescription || hasImage || hasName;
}

@end

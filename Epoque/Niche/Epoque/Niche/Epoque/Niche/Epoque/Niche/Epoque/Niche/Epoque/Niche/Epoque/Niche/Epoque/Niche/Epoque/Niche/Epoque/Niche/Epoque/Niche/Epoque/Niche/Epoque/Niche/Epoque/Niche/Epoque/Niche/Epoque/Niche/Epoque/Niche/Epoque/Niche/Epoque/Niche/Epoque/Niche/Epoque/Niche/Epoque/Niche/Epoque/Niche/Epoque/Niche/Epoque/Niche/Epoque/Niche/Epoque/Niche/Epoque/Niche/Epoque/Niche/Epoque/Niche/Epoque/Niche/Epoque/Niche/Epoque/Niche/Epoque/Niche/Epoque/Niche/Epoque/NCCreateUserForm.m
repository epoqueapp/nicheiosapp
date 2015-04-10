//
//  NCCreateUserForm.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateUserForm.h"

@implementation NCCreateUserForm


-(NSDictionary *)emailField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
             @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0]
             };
}

-(NSDictionary *)passwordField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
            @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0]
             };
}

-(NSDictionary *)nameField{
    return @{
             @"textLabel.font": [UIFont fontWithName:kTrocchiBoldFontName size:16.0],
              @"textField.font": [UIFont fontWithName:kTrocchiFontName size:16.0]
             };
}


@end

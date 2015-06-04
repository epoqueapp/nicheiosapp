//
//  NCCreateUserForm.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NCCreateUserForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *spriteUrl;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;

-(BOOL)isValid;

@end

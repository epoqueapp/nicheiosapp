//
//  NCEditWorldForm.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/11/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NCEditWorldForm : NSObject<FXForm>

@property (nonatomic, strong) UIImage *emblemImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *worldDescription;
@property (nonatomic, assign) BOOL isPrivate;

-(BOOL)isDirty;
-(BOOL)isValid;

@end

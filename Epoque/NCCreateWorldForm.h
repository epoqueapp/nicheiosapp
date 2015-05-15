//
//  NCCreateWorldForm.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>


@interface NCCreateWorldForm : NSObject <FXForm>

@property (nonatomic, strong) UIImage *emblemImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *worldDescription;
@property (nonatomic, assign) BOOL isPrivate;

-(BOOL)isDirty;
-(BOOL)isValid;

@end

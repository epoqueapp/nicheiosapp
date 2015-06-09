//
//  NCBlurbForm.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NCBlurbForm :NSObject <FXForm>

@property (nonatomic, strong) NSString *spriteUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;


@end

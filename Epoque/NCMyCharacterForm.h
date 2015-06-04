//
//  NCMyCharacterForm.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>

@interface NCMyCharacterForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *spriteUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *about;
/*@property (nonatomic, assign) BOOL isObscuring;*/
@end

//
//  NCLoginForm.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms.h>

@interface NCLoginForm : NSObject <FXForm>
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
-(BOOL)isValid;
@end

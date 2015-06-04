//
//  Firebase+AuthenticationExtensions.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Firebase/Firebase.h>

static NSInteger const kNCAuthenticationTemporaryPasswordErrorCode = 98765;
static NSInteger const kNCNameUnavailableCode = 4583435;
static NSInteger const kNCUserNameValidationErrorCode = 96531884;

@interface Firebase (AuthenticationExtensions)

-(RACSignal *)rac_loginWithEmail:(NSString *)email password:(NSString *)password;
-(RACSignal *)rac_createUserWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name about:(NSString *)about spriteUrl:(NSString *)spriteUrl role:(NSString *)role;
-(RACSignal *)rac_changeEmailTo:(NSString *)toEmail fromEmail:(NSString *)fromEmail password:(NSString *)password;
-(RACSignal *)rac_changePasswordForEmail:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

-(RACSignal *)rac_sendPasswordResetForEmail:(NSString *)email;
-(RACSignal *)rac_validateName:(NSString *)name;
@end

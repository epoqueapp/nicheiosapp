//
//  Firebase+AuthenticationExtensions.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "Firebase+AuthenticationExtensions.h"

@implementation Firebase (AuthenticationExtensions)

-(RACSignal *)rac_createUserWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name about:(NSString *)about spriteUrl:(NSString *)spriteUrl role:(NSString *)role{
    
    NSDictionary *userDictionary = @{
                                     @"name":name,
                                     @"email": email,
                                     @"about": about,
                                     @"spriteUrl": spriteUrl,
                                     @"role": role
                                     };
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }] flattenMap:^RACStream *(id value) {
       return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           NSString *userId = [value objectForKey:@"uid"];
           [[[self childByAppendingPath:@"users"] childByAppendingPath:userId] setValue:userDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
               if(error){
                   [subscriber sendError:error];
               }else{
                   [subscriber sendNext:userId];
                   [subscriber sendCompleted];
               }
           }];
           return nil;
       }];
    }] flattenMap:^RACStream *(id value) {
        return [self rac_loginWithEmail:email password:password];
    }];
}

-(RACSignal *)rac_loginWithEmail:(NSString *)email password:(NSString *)password{
    return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                [subscriber sendError:error];
            }else{
                BOOL isTemporaryPassword = [authData.providerData[@"isTemporaryPassword"] boolValue];
                
                if (!isTemporaryPassword) {
                    [subscriber sendNext:authData.uid];
                    [subscriber sendCompleted];
                }else{
                    [subscriber sendError:[NSError errorWithDomain:@"kNCLoginError" code:kNCAuthenticationTemporaryPasswordErrorCode userInfo:nil]];
                }
            }
        }];
        return nil;
    }] flattenMap:^RACStream *(NSString *userId) {
        return [self rac_getUserById:userId];
    }] doNext:^(UserModel *userModel) {
        [Amplitude setUserId:userModel.userId];
        [Amplitude setUserProperties:[userModel toDictionary]];
    }] doError:^(NSError *error) {
        [self unauth];
    }];
}

-(RACSignal *)rac_getUserById:(NSString *)userId{
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self childByAppendingPath:@"users"] childByAppendingPath:userId] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value == [NSNull null]) {
                NSError *error = [NSError errorWithDomain:@"kNCLoginError" code:FAuthenticationErrorUserDoesNotExist userInfo:nil];
                [subscriber sendError:error];
            }else{
                UserModel *userModel = [[UserModel alloc]initWithSnapshot:snapshot];
                [subscriber sendNext:userModel];
            }
        }];
        return nil;
    }] doNext:^(UserModel *userModel) {
        [[NSUserDefaults standardUserDefaults] setUserModel:userModel];
    }] doError:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] clearAuthInformation];
    }];
}

-(RACSignal *)rac_changePasswordForEmail:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self changePasswordForUser:email fromOld:oldPassword toNew:newPassword withCompletionBlock:^(NSError *error) {
            if(error){
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:email];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}


-(RACSignal *)rac_changeEmailTo:(NSString *)toEmail fromEmail:(NSString *)fromEmail password:(NSString *)password{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self changeEmailForUser:fromEmail password:password toNewEmail:toEmail withCompletionBlock:^(NSError *error) {
            if(error){
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }] doNext:^(id x) {
        [[[[self childByAppendingPath:@"users"]childByAppendingPath:self.authData.uid] childByAppendingPath:@"email"] setValue:toEmail];
    }];
}

-(RACSignal *)rac_sendPasswordResetForEmail:(NSString *)email {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self resetPasswordForUser:email withCompletionBlock:^(NSError *error) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:email];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(RACSignal *)rac_validateName:(NSString *)name{
    RACSignal *serverSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[self childByAppendingPath:@"users"] queryOrderedByChild:@"name"] queryEqualToValue:name] queryLimitedToLast:1] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value == [NSNull null]) {
                [subscriber sendNext:name];
                [subscriber sendCompleted];
            }else{
                NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
                NSString *foundUserId = [snapshot.value allKeys].firstObject;
                if ([myUserId isEqualToString:foundUserId]) {
                    [subscriber sendNext:name];
                    [subscriber sendCompleted];
                }else{
                    NSError *error = [NSError errorWithDomain:@"kNCCheckNameErrorDomain" code:kNCNameUnavailableCode userInfo:nil];
                    [subscriber sendError:error];
                }
            }
        }];
        return nil;
    }];
    return [[self rac_validateUserNameStringWithRegex:name] flattenMap:^RACStream *(id value) {
        return serverSignal;
    }];
}

-(RACSignal *)rac_validateUserNameStringWithRegex:(NSString *)userName{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *userNameRegex = @"^@?(\\w){1,15}$";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
        
        
        if ([emailTest evaluateWithObject:userName]) {
            [subscriber sendNext:userName];
            [subscriber sendCompleted];
        }else{
            [subscriber sendError:[NSError errorWithDomain:@"kNCValidationError" code:kNCUserNameValidationErrorCode userInfo:nil]];
        }
        return nil;
    }];
}

@end

//
//  UserModel.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <JSONModel.h>

@interface UserModel : JSONModel

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *spriteUrl;
@property (nonatomic, strong) NSString *role;

-(id)initWithSnapshot:(FDataSnapshot *)dataSnapShot;

@end

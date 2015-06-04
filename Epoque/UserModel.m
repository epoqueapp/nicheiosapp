//
//  UserModel.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

-(id)initWithSnapshot:(FDataSnapshot *)dataSnapShot{
    self = [super init];
    if(self){
        self.userId = dataSnapShot.key;
        self.name = [dataSnapShot.value objectForKey:@"name"];
        self.about = [dataSnapShot.value objectForKey:@"about"];
        self.email = [dataSnapShot.value objectForKey:@"email"];
        self.spriteUrl = [dataSnapShot.value objectForKey:@"spriteUrl"];
        self.role = [dataSnapShot.value objectForKey:@"role"];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err{
    self = [super init];
    if (self) {
        self.userId = [dict objectForKey:@"userId"];
        self.email = [dict objectForKey:@"email"];
        self.spriteUrl = [dict objectForKey:@"spriteUrl"];
        self.name = [dict objectForKey:@"name"];
        self.about = [dict objectForKey:@"about"];
        self.role = [dict objectForKey:@"role"];
    }
    return self;
}

@end

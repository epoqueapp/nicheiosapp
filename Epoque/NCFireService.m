//
//  NCFireService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFireService.h"
#import <HexColors/HexColor.h>
@implementation NCFireService{
    Firebase *rootRef;
    Firebase *worldsRef;
    Firebase *usersRef;
}

+(id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}


-(id)init{
    self = [super init];
    if (self) {
        rootRef = [[Firebase alloc]initWithUrl:kFirebaseRoot];
        worldsRef = [rootRef childByAppendingPath:@"worlds"];
        usersRef = [rootRef childByAppendingPath:@"users"];
    }
    return self;
}

-(RACSignal *)createUserWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name spriteUrl:(NSString *)spriteUrl{
    RACSignal *createSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [rootRef createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    @weakify(self);
    return [createSignal flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self loginWithEmail:email password:password extraInformation:@{@"name": name, @"spriteUrl": spriteUrl, @"about": @"", @"imageUrl": @""}];
    }];
}

-(RACSignal *)loginWithEmail:(NSString *)email password:(NSString *)password extraInformation:(NSDictionary *)extraInformation{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [rootRef authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:authData];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }] doNext:^(FAuthData *authData) {
        [[usersRef childByAppendingPath:authData.uid] setValue:extraInformation];
    }];
}

-(RACSignal *)loginWithEmail:(NSString *)email password:(NSString *)password{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [rootRef authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:authData];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

-(RACSignal *)createWorld:(WorldModel *)worldModel{
    NSDictionary *worldDictionary = [worldModel toDictionary];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[worldsRef childByAutoId] setValue:worldDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                NSString *newWorldId = [ref key];
                worldModel.worldId = newWorldId;
                [subscriber sendNext:worldModel];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(RACSignal *)updateWorld:(WorldModel *)worldModel{
    NSDictionary *worldDictionary = [worldModel toDictionary];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[worldsRef childByAppendingPath:worldModel.worldId] setValue:worldDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(RACSignal *)deleteWorld:(NSString *)worldId{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[worldsRef childByAppendingPath:worldId] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            if(error){
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}


-(RACSignal *)registerUserId:(NSString *)userId deviceToken:(NSString *)deviceToken environment:(NSString *)environment{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self.rootRef childByAppendingPath:@"devices"] childByAppendingPath:userId] setValue:@{@"deviceToken": deviceToken, @"environment": environment, @"deviceType": @"ios"} withCompletionBlock:^(NSError *error, Firebase *ref) {
            if(error){
                [subscriber sendError:error];
            }
            else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(RACSignal *)logout{
    [rootRef unauth];
    return [RACSignal empty];
}

-(FAuthData *)authData{
    return rootRef.authData;
}

-(Firebase *)rootRef{
    return rootRef;
}

-(Firebase *)worldsRef{
    return worldsRef;
}

-(Firebase *)usersRef{
    return usersRef;
}

-(Firebase *)worldMessagesRef:(NSString *)worldId{
    return [[rootRef childByAppendingPath:@"world-messages"] childByAppendingPath:worldId];
}

-(Firebase *)worldShoutsRef:(NSString *)worldId{
    return [[rootRef childByAppendingPath:@"world-shouts"] childByAppendingPath:worldId];
}

-(Firebase *)worldPushBusRef:(NSString *)worldId{
    return [[rootRef childByAppendingPath:@"worlds-push-bus"] childByAppendingPath:worldId];
}

-(Firebase *)worldPushSettings:(NSString *)worldId userId:(NSString *)userId{
    return [[[rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:worldId] childByAppendingPath:userId];
}

@end

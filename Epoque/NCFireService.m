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
    CLLocationManager *locationManager;
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
        rootRef = [[Firebase alloc]initWithUrl:@"https://niche.firebaseio.com"];
        worldsRef = [rootRef childByAppendingPath:@"worlds"];
        usersRef = [rootRef childByAppendingPath:@"users"];
        self.lastKnownLocation = [[CLLocation alloc]initWithLatitude:0 longitude:0];
        
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
        [locationManager startUpdatingLocation];
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.lastKnownLocation = [locations objectAtIndex:0];
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

-(RACSignal *)createWorldWithName:(NSString *)name detail:(NSString *)detail imageUrl:(NSString *)imageUrl isPrivate:(BOOL)isPrivate isUnlisted:(BOOL)isUnlisted foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor{
    NSDictionary *worldDictionary = @{
                                      @"name": name,
                                      @"detail": detail,
                                      @"imageUrl": imageUrl,
                                      @"isPrivate": @(isPrivate),
                                      @"isUnlisted": @(isUnlisted),
                                      @"foregroundColor": [foregroundColor hexStringFromColor],
                                      @"backgroundColor": [backgroundColor hexStringFromColor]
                                      };
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[worldsRef childByAutoId] setValue:worldDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
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

-(RACSignal *)submitWorldMessage:(NSString *)worldId myUserId:(NSString *)myUserId mySpriteUrl:(NSString *)mySpriteUrl myName:(NSString *)myName myUserImageUrl:(NSString *)myUserImageUrl text:(NSString *)text imageUrl:(NSString *)imageUrl{

    

    NSDictionary *json = @{
                           @"userId": myUserId,
                           @"userSpriteUrl": mySpriteUrl,
                           @"userName": myName,
                           @"userImageUrl": myUserImageUrl,
                           @"messageText": text,
                           @"messageImageUrl": imageUrl,
                           @"timestamp": [NSDate javascriptTimestampNow],
                           @"geo": [self.lastKnownLocation toGeoJsonWthObscurity:[NSUserDefaults standardUserDefaults].obscurity]
                           };
    
    // world-messages/worldId/messageId/messagedata
    RACSignal *chatSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self worldMessagesRef:worldId] childByAutoId] setValue:json withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    
    RACSignal *shoutSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self worldShoutsRef:worldId] childByAppendingPath:myUserId] setValue:json withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    RACSignal *worldPushNote = [self submitWorldPushNoteWithWorldId:worldId userId:myUserId userName:myName messageText:text messageImageUrl:imageUrl];
    return [RACSignal combineLatest:@[chatSignal, shoutSignal, worldPushNote]];
}

-(RACSignal *)submitPrivateMessage:(SubmitPrivateMessageModel *)submitPrivateMessageModel{
    RACSignal *submitToMyInbox = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[self.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:submitPrivateMessageModel.myUserId] childByAppendingPath:submitPrivateMessageModel.toUserId] setValue:submitPrivateMessageModel.toDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    RACSignal *submitToOtherInbox = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[self.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:submitPrivateMessageModel.toUserId] childByAppendingPath:submitPrivateMessageModel.myUserId] setValue:submitPrivateMessageModel.toDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    RACSignal *submitToMyConversations = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[self.rootRef childByAppendingPath:@"user-conversations"] childByAppendingPath:submitPrivateMessageModel.myUserId] childByAppendingPath:submitPrivateMessageModel.toUserId] setValue:submitPrivateMessageModel.toDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    RACSignal *submitToOtherConversations = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[self.rootRef childByAppendingPath:@"user-conversations"] childByAppendingPath:submitPrivateMessageModel.toUserId] childByAppendingPath:submitPrivateMessageModel.myUserId] setValue:submitPrivateMessageModel.toDictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
    return [RACSignal combineLatest:@[submitToMyInbox, submitToOtherInbox, submitToMyConversations, submitToOtherConversations]];
}


-(RACSignal *)registerUserId:(NSString *)userId deviceToken:(NSString *)deviceToken environment:(NSString *)environment{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[self.rootRef childByAppendingPath:@"apple-devices"] childByAppendingPath:userId] setValue:@{@"deviceToken": deviceToken, @"environment": environment} withCompletionBlock:^(NSError *error, Firebase *ref) {
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


-(RACSignal *)submitWorldPushNoteWithWorldId:(NSString *)worldId userId:(NSString *)userId userName:(NSString *)userName messageText:(NSString *)messageText messageImageUrl:(NSString *)messageImageUrl{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[[rootRef childByAppendingPath:@"worlds-push-bus"] childByAppendingPath:worldId] setValue:@{@"userId": userId, @"userName": userName, @"messageText": messageText, @"messageImageUrl": messageImageUrl} withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error) {
                    [subscriber sendError:error];
                }else{
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

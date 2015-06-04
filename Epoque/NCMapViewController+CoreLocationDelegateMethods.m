//
//  NCMapViewController+CoreLocationDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+CoreLocationDelegateMethods.h"

@implementation NCMapViewController (CoreLocationDelegateMethods)

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.lastKnownLocation = locations.firstObject;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kNCIsLocationUpdateOn] boolValue] == NO) {
        return;
    }
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [[[self doesWorldShoutExist:self.worldId userId:userId] flattenMap:^RACStream *(id value) {
        return [self updateWorldShoutGeo:self.worldId userId:userId];
    }] subscribeNext:^(id x) {
    }];
}


-(RACSignal *)updateWorldShoutGeo:(NSString *)worldId userId:(NSString *)userId{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] childByAppendingPath:userId] childByAppendingPath:@"geo"] setValue:[self.lastKnownLocation toGeoJson] withCompletionBlock:^(NSError *error, Firebase *ref) {
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

-(RACSignal *)doesWorldShoutExist:(NSString *)worldId userId:(NSString *)userId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:worldId] childByAppendingPath:userId] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if([snapshot.value isKindOfClass:[NSNull class]]){
                [subscriber sendError:nil];
            }else{
                [subscriber sendNext:snapshot];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

@end

//
//  UserAnnotation.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        [self upsertFromSnapshot:snapshot];
    }
    return self;
}

-(void)upsertFromSnapshot:(FDataSnapshot *)snapshot{
    self.userId = [snapshot.key copy];
    self.userImageUrl = [snapshot.value objectForKey:@"userImageUrl"];
    self.userSpriteUrl = [snapshot.value objectForKey:@"userSpriteUrl"];
    self.userName = [snapshot.value objectForKey:@"userName"];
    self.messageId = [snapshot.value objectForKey:@"messageId"];
    self.messageText = [snapshot.value objectForKey:@"messageText"];
    self.messageImageUrl = [snapshot.value objectForKey:@"messageImageUrl"];
    self.timestamp = [NSDate dateFromJavascriptTimestamp:[snapshot.value objectForKey:@"timestamp"]];
    self.isObscuring = [[snapshot.value objectForKey:@"isObscuring"] boolValue];
    
    float longitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:0] floatValue];
    float latitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
    
    @weakify(self);
    [UIView animateWithDuration:0.10 animations:^{
        @strongify(self);
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }];
    
}

@end

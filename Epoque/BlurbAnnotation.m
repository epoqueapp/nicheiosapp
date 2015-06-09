//
//  BlurbAnnotation.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "BlurbAnnotation.h"

@implementation BlurbAnnotation

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        [self upsertFromSnapshot:snapshot];
    }
    return self;
}

-(void)upsertFromSnapshot:(FDataSnapshot *)snapshot{
    self.blurbId = [snapshot.key copy];
    self.spriteUrl = [snapshot.value objectForKey:@"spriteUrl"];
    self.name = [snapshot.value objectForKey:@"name"];
    self.detail = [snapshot.value objectForKey:@"detail"];
    self.websiteUrl = [snapshot.value objectForKey:@"websiteUrl"];
    self.address = [snapshot.value objectForKey:@"address"];
    self.worldId = [snapshot.value objectForKey:@"worldId"];
    
    self.timestamp = [NSDate dateFromJavascriptTimestamp:[snapshot.value objectForKey:@"timestamp"]];
    float longitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:0] floatValue];
    float latitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
    @weakify(self);
    [UIView animateWithDuration:0.10 animations:^{
        @strongify(self);
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }];
    
}

@end

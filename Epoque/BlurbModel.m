//
//  BlurbModel.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "BlurbModel.h"

@implementation BlurbModel

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        self.blurbId = [snapshot.key copy];
        self.name = [snapshot.value objectForKey:@"name"];
        self.detail = [snapshot.value objectForKey:@"detail"];
        self.address = [snapshot.value objectForKey:@"address"];
        self.spriteUrl = [snapshot.value objectForKey:@"spriteUrl"];
        self.websiteUrl = [snapshot.value objectForKey:@"websiteUrl"];
        self.creatorUserId = [snapshot.value objectForKey:@"creatorUserId"];
        float latitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
        float longitude = [[[snapshot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
        self.geo = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

@end

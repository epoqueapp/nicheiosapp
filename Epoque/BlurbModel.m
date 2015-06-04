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
    }
    return self;
}

@end

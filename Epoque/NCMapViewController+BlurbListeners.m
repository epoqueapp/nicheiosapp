//
//  NCMapViewController+BlurbListeners.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+BlurbListeners.h"

@implementation NCMapViewController (BlurbListeners)

-(void)setUpBlurbListeners:(id)sender{
    @weakify(self);
    Firebase *blurbsRef = [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-blurbs"] childByAppendingPath:self.worldId];
    [blurbsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        BlurbAnnotation *blurbAnnotation = [[BlurbAnnotation alloc]initWithSnapshot:snapshot];
        [self.mapView addAnnotation:blurbAnnotation];
        [self.blurbAnnotations setObject:blurbAnnotation forKey:snapshot.key];
    }];
    
    [blurbsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        BlurbAnnotation *blurbAnnotation = [self.blurbAnnotations objectForKey:snapshot.key];
        if (blurbAnnotation){
            [blurbAnnotation upsertFromSnapshot:snapshot];
            [self.blurbAnnotations setObject:blurbAnnotation forKey:snapshot.key];
        }

    }];
    
    [blurbsRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        BlurbAnnotation *blurbAnnotation = [self.blurbAnnotations objectForKey:snapshot.key];
        if (blurbAnnotation){
            [self.mapView removeAnnotation:blurbAnnotation];
            [self.blurbAnnotations removeObjectForKey:snapshot.key];
        }
    }];
}

@end

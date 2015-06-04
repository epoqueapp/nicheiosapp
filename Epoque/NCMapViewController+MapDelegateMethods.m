//
//  NCMapViewController+MapDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+MapDelegateMethods.h"
#import "NCMapViewController+Utilities.h"
@implementation NCMapViewController (MapDelegateMethods)

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if(self.textView.isFirstResponder){
        [self.textView resignFirstResponder];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[UserAnnotation class]]) {
        UserAnnotation *userAnno = (UserAnnotation *)annotation;
        UserAnnotationView *userAnnotationView = (UserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kNCUserAnnotationIdentifier];
        if (userAnnotationView == nil) {
            userAnnotationView = [[UserAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kNCUserAnnotationIdentifier];
        }
        userAnnotationView.annotation = annotation;
        userAnnotationView.userAnnotation = userAnno;
        return userAnnotationView;
    }
    return nil;
};

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [mapView deselectAnnotation:view.annotation animated:NO];
    if([view isKindOfClass:[UserAnnotationView class]]){
        UserAnnotationView *userAnnotationView = (UserAnnotationView *)view;
        
        UIColor *color = [UIColor colorWithHexString:@"#2AA608"];
        [userAnnotationView animateCenterRing:color];
        UserAnnotation *userAnnotation = userAnnotationView.userAnnotation;
        [self setChatPreviewViewWithUserId:userAnnotation.userId spriteUrl:userAnnotation.userSpriteUrl name:userAnnotation.userName messageText:userAnnotation.messageText messageImageUrl:userAnnotation.messageImageUrl timestamp:userAnnotation.timestamp backgroundColor:color];
        
        [UIView animateWithDuration:2.0 delay:2.0 options:0 animations:^{
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        } completion:^(BOOL finished) {
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        }];
    }
}

@end

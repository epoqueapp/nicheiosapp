//
//  NCMapViewController+MapDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+MapDelegateMethods.h"
#import "NCMapViewController+Utilities.h"
#import "NCBlurbDetailViewController.h"
#import "NCNavigationController.h"
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
    if([annotation isKindOfClass:[BlurbAnnotation class]]){
        BlurbAnnotation *blurbAnno = (BlurbAnnotation *)annotation;
        BlurbAnnotationView *blurbAnnotationView = (BlurbAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kNCBlurbAnnotationReuseIdentifier];
        if (blurbAnnotationView == nil) {
            blurbAnnotationView = [[BlurbAnnotationView alloc]initWithAnnotation:blurbAnno reuseIdentifier:kNCBlurbAnnotationReuseIdentifier];
        }
        blurbAnnotationView.annotation = annotation;
        blurbAnnotationView.blurbAnnotation = blurbAnno;
        return blurbAnnotationView;
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
        
        if ([userAnnotation.messageImageUrl length] > 0) {
            [self showImageModalWithUrl:userAnnotation.messageImageUrl];
        }
        
        [UIView animateWithDuration:2.0 delay:2.0 options:0 animations:^{
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        } completion:^(BOOL finished) {
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        }];
    }
    if ([view isKindOfClass:[BlurbAnnotationView class]]) {
        BlurbAnnotation *blurbAnnotation = ((BlurbAnnotation *)view.annotation);
        NCBlurbDetailViewController *blurbDetail = [[NCBlurbDetailViewController alloc]initWithWorldId:self.worldId blurbId:blurbAnnotation.blurbId];
        NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:blurbDetail];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        aView.lineWidth = 10;
        return aView;
    }
    return nil;
}

@end

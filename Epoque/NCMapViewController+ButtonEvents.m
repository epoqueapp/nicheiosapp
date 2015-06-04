//
//  NCMapViewController+ButtonEvents.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import "AppDelegate.h"
#import "NCMapViewController+ButtonEvents.h"
#import <RESideMenu/RESideMenu.h>
#import "NCUsersTableViewController.h"
#import "NCNavigationController.h"
@implementation NCMapViewController (ButtonEvents)



-(void)menuButtonDidTap:(id)sender{
    self.sideMenuViewController.scaleContentView = YES;
    self.sideMenuViewController.contentViewInPortraitOffsetCenterX = 30;
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)searchButtonDidClick:(id)sender{
    self.sideMenuViewController.scaleContentView = NO;
    self.sideMenuViewController.contentViewInPortraitOffsetCenterX = 100;
    [self.sideMenuViewController presentRightMenuViewController];
}

-(void)bellButtonButtonDidTap:(id)sender{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSString *deviceToken = [NSUserDefaults standardUserDefaults].deviceToken;
    Firebase *path = [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-listeners"] childByAppendingPath:self.worldId] childByAppendingPath:myUserId];
    if (self.isListening) {
        //remove
        [path removeValue];
        NSString *message = @"Turning OFF push notification for this world";
        [CSNotificationView showInViewController:self tintColor:[UIColor blackColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }else{
        //add
        [path setValue:@{
                         @"deviceType": @"ios",
                         @"deviceToken": deviceToken,
                         @"environment": [AppDelegate buildConfiguration]
                         }];
        NSString *message = @"Turning ON push notification for this world";
        [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }
}

-(void)worldHolderDidTap:(id)sender{
    if (self.worldModel == nil) {
        return;
    }
    [self.textView resignFirstResponder];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    BOOL isModerator = [self.worldModel.moderatorUserIds containsObject:myUserId];
    BOOL isFavorite = [self.worldModel.favoritedUserIds containsObject:myUserId];
    BOOL isMember = [self.worldModel.favoritedUserIds containsObject:myUserId];
    NSMutableArray *titles = [NSMutableArray array];
    [titles addObject:kViewWorldDetailsTitle];
    [titles addObject:kViewWorldUsersTitle];
    if (isFavorite) {
        [titles addObject:kUnfavoriteWorldTitle];
    }else{
        [titles addObject:kFavoriteWorldTitle];
    }
    IBActionSheet *actionSheet = [[IBActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (int i = 0; i < [titles count]; i++) {
        NSString *title = [titles objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
        [actionSheet setButtonTextColor:[UIColor whiteColor] forButtonAtIndex:i];
        [actionSheet setButtonBackgroundColor:[UIColor colorWithHexString:@"#141414"] forButtonAtIndex:i];
    }
    [actionSheet setButtonTextColor:[UIColor whiteColor]];
    [actionSheet setButtonBackgroundColor:[UIColor colorWithHexString:@"#141414"]];
    [actionSheet setFont:[UIFont fontWithName:kTrocchiBoldFontName size:17.0]];
    [actionSheet showInView:self.view];
}

-(void)mapButtonDidTap:(id)sender{
    [[NSUserDefaults standardUserDefaults] setWorldMapEnabled:YES];
}

-(void)tableButtonDidTap:(id)sender{
    [[NSUserDefaults standardUserDefaults] setWorldMapEnabled:NO];
}

-(void)centerMeButtonDidTap:(id)sender{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    UserAnnotation *userAnnotation = [self.userAnnotations objectForKey:myUserId];
    if (userAnnotation) {
        self.mapView.centerCoordinate = userAnnotation.coordinate;
        UserAnnotationView *annotationView = (UserAnnotationView *)[self.mapView viewForAnnotation:userAnnotation];
        if (annotationView) {
            [annotationView animateCenterRing:[UIColor blueColor]];
        }
    }
}

-(void)locationUpdateButtonDidTap:(id)sender{
    BOOL currentIsEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:kNCIsLocationUpdateOn] boolValue];
    [[NSUserDefaults standardUserDefaults] setObject:@(!currentIsEnabled) forKey:kNCIsLocationUpdateOn];
    BOOL isUpdating = [[[NSUserDefaults standardUserDefaults] objectForKey:kNCIsLocationUpdateOn] boolValue];
    if (isUpdating) {
        NSString *message = @"Location Auto Update is Now ON";
        [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }else{
        NSString *message = @"Location Auto Update is Now OFF";
        [CSNotificationView showInViewController:self tintColor:[UIColor darkGrayColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }
}



-(void)chatPreviewViewDidTap:(id)sender{
    UserAnnotation *userAnnotation = [self.userAnnotations objectForKey:self.chatPreviewUserId];
    if (userAnnotation == nil) {
        return;
    }
    self.mapView.centerCoordinate = userAnnotation.coordinate;
    UserAnnotationView *annotationView = (UserAnnotationView*)[self.mapView viewForAnnotation:userAnnotation];
    if (annotationView) {
        [annotationView animateCenterRing];
    }
}

-(void)didPressLeftButton:(id)sender{
    [self.textView resignFirstResponder];
    @weakify(self);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:kCameraTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:kGalleryTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:kPlaceTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    [super didPressLeftButton:sender];
}

-(void)didPressRightButton:(id)sender{
    SendMessageModel *sendMessageModel = [[SendMessageModel alloc]init];
    sendMessageModel.messageText = self.textView.text;
    sendMessageModel.location = self.lastKnownLocation;
    [self sendMessage:sendMessageModel];
    [super didPressRightButton:sender];
}

-(void)removeMeButtonDidTap:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to remove yourself from the map?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] childByAppendingPath: myUserId] removeValue];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)openUsersTableViewController:(id)sender{
    NCUsersTableViewController *usersViewController = [[NCUsersTableViewController alloc]init];
    usersViewController.worldId = [self.worldId copy];
    NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:usersViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)handleFavoriting:(id)sender{
    NSMutableSet *favoritedUserIds = [NSMutableSet setWithArray:self.worldModel.favoritedUserIds];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if ([favoritedUserIds containsObject:myUserId]) {
        [favoritedUserIds removeObject:myUserId];
    }else{
        [favoritedUserIds addObject:myUserId];
    }
    [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"] childByAppendingPath:self.worldId] childByAppendingPath:@"favoritedUserIds"] setValue:favoritedUserIds.allObjects];
}

@end

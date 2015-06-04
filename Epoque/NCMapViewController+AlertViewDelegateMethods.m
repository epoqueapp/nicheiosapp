//
//  NCMapViewController+AlertViewDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+AlertViewDelegateMethods.h"

@implementation NCMapViewController (AlertViewDelegateMethods)

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kBlockUserTitle]) {
        [[NSUserDefaults standardUserDefaults] blockUserWithId:self.userIdToBlock];
        [CSNotificationView showInViewController:self tintColor:[UIColor blackColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Sorry for that experience. We're on it" duration:2.0];
    }
    if ([buttonTitle isEqualToString:kReportUserTitle]) {
        [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"user-reports"] childByAutoId] setValue:@{
                                                                                                                       @"reporteeUserId": self.userIdToReport,
                                                                                                                       @"reporterUserId": [NSUserDefaults standardUserDefaults].userModel.userId,
                                                                                                                       @"timestamp": kFirebaseServerValueTimestamp
                                                                                                                       }];
        [CSNotificationView showInViewController:self tintColor:[UIColor blackColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Sorry for that experience. We're on it" duration:2.0];
    }
    if ([buttonTitle isEqualToString:kRemoveMeConfirmTitle]) {
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] childByAppendingPath: myUserId] removeValue];
    }
}

@end

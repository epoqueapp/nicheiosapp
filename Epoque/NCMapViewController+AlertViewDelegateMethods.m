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
        
    }
    if ([buttonTitle isEqualToString:kReportUserTitle]) {
        
    }
    if ([buttonTitle isEqualToString:kRemoveMeConfirmTitle]) {
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] childByAppendingPath: myUserId] removeValue];
    }
}

@end

//
//  NCMapViewController+ActionSheetDelegateMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+ActionSheetDelegateMethods.h"

@implementation NCMapViewController (ActionSheetDelegateMethods)





-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kPlaceTitle]) {
        
    }
    if([buttonTitle isEqualToString:kViewWorldUsersTitle]){

    }
    if ([buttonTitle isEqualToString:kFavoriteWorldTitle] || [buttonTitle isEqualToString:kUnfavoriteWorldTitle]) {

    }
    if ([buttonTitle isEqualToString:kGalleryTitle]) {
        
    }
    if ([buttonTitle isEqualToString:kCameraTitle]) {
        
    }
    if ([buttonTitle isEqualToString:kReportUserTitle]){
        [[[UIAlertView alloc]initWithTitle:nil message:@"Are you user you want to report this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kReportUserTitle, nil]show ];
    }
    if ([buttonTitle isEqualToString:kBlockUserTitle]){
        [[[UIAlertView alloc]initWithTitle:nil message:@"Are you user you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kBlockUserTitle, nil]show ];
    }
}

@end

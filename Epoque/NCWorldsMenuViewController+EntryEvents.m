//
//  NCWorldsMenuViewController+EntryEvents.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldsMenuViewController+EntryEvents.h"
#import "NCMapViewController.h"
@implementation NCWorldsMenuViewController (EntryEvents)

-(void)attemptEntryToWorld:(WorldModel *)worldModel{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    BOOL isRequirePasscodeEntry = worldModel.isPrivate && ![worldModel.memberUserIds containsObject:myUserId];
    if (isRequirePasscodeEntry) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Secret" message:@"What's the secret" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.font = [UIFont fontWithName:kTrocchiBoldFontName size:16.0];
            textField.textAlignment = NSTextAlignmentCenter;
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alert.textFields.firstObject;
            NSString *text = textField.text;
            
            if ([worldModel.passcode isEqualToString:text]) {
                [self commitEnterWorld:worldModel];
            }else{
                [self showFailureAlert];
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self commitEnterWorld:worldModel];
}


-(void)addToMembers:(WorldModel *)worldModel userId:(NSString *)userId{
    NSMutableSet *memberUserIds = [NSMutableSet setWithArray:worldModel.memberUserIds];
    [memberUserIds addObject:userId];
    [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"]childByAppendingPath:worldModel.worldId] childByAppendingPath:@"memberUserIds"] setValue:memberUserIds.allObjects];
}

-(void)commitEnterWorld:(WorldModel *)worldModel {
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [self addToMembers:worldModel userId:myUserId];
    
    [[NSUserDefaults standardUserDefaults] setCurrentWorldId:worldModel.worldId];
    
    NCMapViewController *mapViewController = [[NCMapViewController alloc]initWithWorldId:worldModel.worldId];
    [self.sideMenuViewController customSetContentViewController:mapViewController];
    [self.sideMenuViewController hideMenuViewController];
}

-(void)showFailureAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nope!" message:@"Please check if you have the right secret." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

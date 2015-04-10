//
//  NCInviteUsersViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCInviteUsersViewController.h"
#import "NCFireService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface NCInviteUsersViewController ()

@end

@implementation NCInviteUsersViewController{
    NSArray *users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.worldName;
    [self setUpBackButton];
    users = [NSArray array];
    @weakify(self);
    [[[[NCFireService sharedInstance] worldsRef] childByAppendingPath:self.worldId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value != [NSNull null]) {
            self.title = [snapshot.value objectForKey:@"name"];
        }
    }];
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonDidClick:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(void)dismissButtonDidClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

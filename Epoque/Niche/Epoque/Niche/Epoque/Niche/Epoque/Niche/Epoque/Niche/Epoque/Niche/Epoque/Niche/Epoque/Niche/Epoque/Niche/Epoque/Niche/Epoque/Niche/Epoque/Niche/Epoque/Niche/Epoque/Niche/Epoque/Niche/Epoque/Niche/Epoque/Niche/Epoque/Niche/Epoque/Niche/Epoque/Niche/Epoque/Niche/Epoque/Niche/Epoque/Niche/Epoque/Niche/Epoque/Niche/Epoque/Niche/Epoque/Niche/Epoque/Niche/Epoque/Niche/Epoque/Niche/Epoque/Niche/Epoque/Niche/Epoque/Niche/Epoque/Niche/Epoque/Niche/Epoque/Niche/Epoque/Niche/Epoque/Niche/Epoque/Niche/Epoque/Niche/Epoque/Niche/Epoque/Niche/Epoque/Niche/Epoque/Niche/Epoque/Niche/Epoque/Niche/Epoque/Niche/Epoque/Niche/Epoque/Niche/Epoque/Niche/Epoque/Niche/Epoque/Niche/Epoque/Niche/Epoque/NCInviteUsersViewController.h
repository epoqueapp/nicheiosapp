//
//  NCInviteUsersViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCRefreshDelegate.h"

@interface NCInviteUsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, copy) NSString *worldName;

@property (nonatomic, assign) id<NCRefreshDelegate> delegate;

@end

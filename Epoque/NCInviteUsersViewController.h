//
//  NCInviteUsersViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCRefreshDelegate.h"

@interface NCInviteUsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, copy) NSString *worldName;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, assign) id<NCRefreshDelegate> delegate;

@end

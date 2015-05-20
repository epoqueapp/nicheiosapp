//
//  NCUsersTableViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/17/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCUsersTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *worldId;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

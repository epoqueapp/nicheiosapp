//
//  NCUsersViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorldModel.h"
@interface NCUsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) WorldModel *worldModel;

@end

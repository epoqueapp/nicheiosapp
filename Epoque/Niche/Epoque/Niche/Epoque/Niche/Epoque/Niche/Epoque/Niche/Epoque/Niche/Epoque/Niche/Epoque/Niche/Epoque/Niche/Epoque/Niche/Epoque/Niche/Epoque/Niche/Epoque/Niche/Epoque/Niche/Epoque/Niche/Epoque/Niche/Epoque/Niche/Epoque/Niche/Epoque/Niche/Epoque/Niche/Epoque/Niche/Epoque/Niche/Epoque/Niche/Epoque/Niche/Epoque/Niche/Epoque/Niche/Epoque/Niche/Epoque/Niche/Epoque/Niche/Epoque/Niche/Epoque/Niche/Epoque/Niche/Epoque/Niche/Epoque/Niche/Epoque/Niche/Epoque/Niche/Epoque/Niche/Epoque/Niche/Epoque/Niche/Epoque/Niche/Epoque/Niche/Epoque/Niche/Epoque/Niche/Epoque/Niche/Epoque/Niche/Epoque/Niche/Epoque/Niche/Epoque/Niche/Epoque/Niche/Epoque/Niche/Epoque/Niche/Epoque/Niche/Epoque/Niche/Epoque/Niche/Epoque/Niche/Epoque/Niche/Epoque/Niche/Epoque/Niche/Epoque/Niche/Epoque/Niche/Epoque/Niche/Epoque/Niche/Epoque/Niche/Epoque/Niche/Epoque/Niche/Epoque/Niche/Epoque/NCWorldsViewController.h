//
//  NCWorldsViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCCreateNewWorldViewController.h"

@interface NCWorldsViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, NCRefreshDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

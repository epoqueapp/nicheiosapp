//
//  NCWorldsMenuViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCWorldTableViewCell.h"
#import "WorldModel.h"
@interface NCWorldsMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *customNavbar;
@property (nonatomic, strong) NSMutableArray *worlds;



@end

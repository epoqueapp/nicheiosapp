//
//  NCConversationsViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCConversationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

//
//  NCLeftMenuViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NCLeftMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIImageView *hourHandImageView;
@property (nonatomic, weak) IBOutlet UIImageView *minuteHandImageView;
@property (nonatomic, weak) IBOutlet UIImageView *flareImageView;

@end

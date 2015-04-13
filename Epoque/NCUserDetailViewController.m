//
//  NCUserDetailViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUserDetailViewController.h"
#import "NCPrivateChatViewController.h"
@interface NCUserDetailViewController ()

@end

@implementation NCUserDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"User";
    [self setUpBackButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:57.0/255 blue:76.0/255.0 alpha:1.0];
    
    self.nameLabel.text = self.userName;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:self.spriteImageUrl]];
    self.messageTextView.text = self.messageText;
    self.messageTextView.layer.cornerRadius = 3.0;
    self.messageTextView.layer.masksToBounds = YES;
    self.messageTextView.backgroundColor = [UIColor darkGrayColor];
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.editable = NO;
    self.timeLabel.text = self.timestamp.tableViewCellTimeString;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.messageImageView.image = [UIImage imageNamed:@"placeholder"];
    [self.messageImageView sd_setImageWithURL:[NSURL URLWithString:self.messageImageUrl]];
    self.privateMessageButton.layer.cornerRadius = 3.0;
    self.privateMessageButton.layer.masksToBounds = YES;
    [self.privateMessageButton addTarget:self action:@selector(privateMessageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)privateMessageButtonDidClick:(id)sender{
    NCPrivateChatViewController *privateChatViewController = [[NCPrivateChatViewController alloc]init];
    privateChatViewController.regardingUserId = self.userId;
    privateChatViewController.regardingUserName = self.userName;
    [self.navigationController pushViewController:privateChatViewController animated:YES];
}



@end

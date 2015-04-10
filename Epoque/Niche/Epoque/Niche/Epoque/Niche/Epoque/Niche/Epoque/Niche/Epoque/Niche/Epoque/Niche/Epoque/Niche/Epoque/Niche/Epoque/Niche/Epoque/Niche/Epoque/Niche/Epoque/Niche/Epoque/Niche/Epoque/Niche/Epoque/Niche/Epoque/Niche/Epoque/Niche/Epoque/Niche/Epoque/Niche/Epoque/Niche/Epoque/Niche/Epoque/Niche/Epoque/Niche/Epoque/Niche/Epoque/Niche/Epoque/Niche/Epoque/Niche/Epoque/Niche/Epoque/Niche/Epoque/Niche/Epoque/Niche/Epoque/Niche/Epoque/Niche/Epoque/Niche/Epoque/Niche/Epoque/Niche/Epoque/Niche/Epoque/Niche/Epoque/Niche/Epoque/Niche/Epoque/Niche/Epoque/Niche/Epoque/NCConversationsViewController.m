//
//  NCConversationsViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCConversationsViewController.h"
#import "NCConversationTableViewCell.h"
#import "ConversationModel.h"
@interface NCConversationsViewController ()

@end

@implementation NCConversationsViewController{
    NSMutableArray *conversations;
}
static NSString *CellIdentifier = @"CellIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpMenuButton];
    self.title = @"MESSAGES";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"NCConversationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    conversations = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return conversations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCConversationTableViewCell *cell = (NCConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ConversationModel *conversationModel = [conversations objectAtIndex:indexPath.row];
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:conversationModel.regardingUserSpriteUrl]];
    cell.nameLabel.text = conversationModel.regardUserName;
    cell.summaryTextView.text = conversationModel.summaryText;
    cell.timeLabel.text = conversationModel.timestamp.tableViewCellTimeString;
    return cell;
}


@end

//
//  NCConversationsViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCConversationsViewController.h"
#import "NCPrivateChatViewController.h"
#import "NCConversationTableViewCell.h"

#import "NCFireService.h"
#import "ConversationModel.h"
@interface NCConversationsViewController ()

@end

@implementation NCConversationsViewController{
    NCFireService *fireService;
}
static NSString *CellIdentifier = @"CellIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self setUpMenuButton];
    self.title = @"MESSAGES";
    self.conversations = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70.0f;
    [self.tableView registerNib:[UINib nibWithNibName:@"NCConversationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    fireService = [NCFireService sharedInstance];
    
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    
    FQuery *myConversations = [[[[fireService.rootRef childByAppendingPath:@"user-conversations"] childByAppendingPath:myUserId] childByAppendingPath:@"conversations"] queryOrderedByChild:@"timestamp"];
    
    [myConversations observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        self.conversations = [NSMutableArray array];
        if (snapshot.value == [NSNull null]) {
            return ;
        }
        
        for (NSString *key in snapshot.value) {
            NSDictionary *dict = [snapshot.value objectForKey:key];
            ConversationModel *model = [[ConversationModel alloc]initWithSubvalue:key dictionary:dict];
            [self.conversations insertObject:model atIndex:0];
        }
        
        [self.conversations sortUsingComparator:^NSComparisonResult(ConversationModel *obj1, ConversationModel *obj2){
            return [obj2.timestamp compare:obj1.timestamp];
        }];
        
        [self.tableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.conversations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCConversationTableViewCell *cell = (NCConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ConversationModel *conversationModel = [self.conversations objectAtIndex:indexPath.row];
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:conversationModel.regardingUserSpriteUrl]];
    cell.nameLabel.text = conversationModel.regardUserName;
    
    
    cell.summaryTextView.text = conversationModel.messageText;
    
    if (conversationModel.messageImageUrl.length > 0) {
        cell.summaryTextView.text = @"Sent an Image";
    }
    
    
    cell.summaryTextView.font = [UIFont fontWithName:kTrocchiFontName size:11.0];
    cell.summaryTextView.userInteractionEnabled = NO;
    cell.timeLabel.text = conversationModel.timestamp.tableViewCellTimeString;
    cell.nameLabel.userInteractionEnabled = NO;
    cell.timeLabel.userInteractionEnabled = NO;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ConversationModel *conversationModel = [self.conversations objectAtIndex:indexPath.row];
    
    NCPrivateChatViewController *privateChatViewController = [[NCPrivateChatViewController alloc]init];
    privateChatViewController.regardingUserId = conversationModel.regardingUserId;
    privateChatViewController.regardingUserName = conversationModel.regardUserName;
    privateChatViewController.regardingUserSpriteUrl = conversationModel.regardingUserSpriteUrl;
    [self.navigationController pushRetroViewController:privateChatViewController];
    
}


@end

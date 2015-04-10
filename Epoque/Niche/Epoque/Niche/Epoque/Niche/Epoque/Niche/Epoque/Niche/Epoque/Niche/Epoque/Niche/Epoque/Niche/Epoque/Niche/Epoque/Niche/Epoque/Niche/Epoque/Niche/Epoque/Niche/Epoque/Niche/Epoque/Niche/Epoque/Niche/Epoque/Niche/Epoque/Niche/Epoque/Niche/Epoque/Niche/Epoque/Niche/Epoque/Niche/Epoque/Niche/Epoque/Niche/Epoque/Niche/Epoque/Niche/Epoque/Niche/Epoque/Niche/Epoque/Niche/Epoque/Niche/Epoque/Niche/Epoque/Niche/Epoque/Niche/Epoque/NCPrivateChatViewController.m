//
//  NCPrivateChatViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCPrivateChatViewController.h"
#import "NCFireService.h"
#import "NCMessageTableViewCell.h"
#import "NCImageMessageTableViewCell.h"

@interface NCPrivateChatViewController ()

@end

@implementation NCPrivateChatViewController{
    Mixpanel *mixpanel;
    NCSoundEffect *shoutSound;
    NCSoundEffect *tableShoutSound;
    NCFireService *fireService;
    BOOL initialAdds;
}

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *ImageMessageCellIdentifier = @"ImageMessageCell";
static NSString *CameraTitle = @"Camera";
static NSString *GalleryTitle = @"Gallery";

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    self.title = self.regardingUserName;
    [self setUpBackButton];
    initialAdds = YES;
    mixpanel = [Mixpanel sharedInstance];
    fireService = [NCFireService sharedInstance];
    shoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"shout.wav"];
    tableShoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    self.view.backgroundColor = [UIColor colorWithRed:22.0/255.0 green:37.0/255 blue:56.0/255.0 alpha:1.0];
    
    self.messages = [NSMutableArray array];
    self.bounces = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"NCMessageTableViewCell" bundle:nil] forCellReuseIdentifier:MessengerCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCImageMessageTableViewCell" bundle:nil] forCellReuseIdentifier:ImageMessageCellIdentifier];
    
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.rightButton.titleLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:16.0];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];

}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    [self.tableView reloadData];
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    [super didCancelTextEditing:sender];
}

-(void)didPressRightButton:(id)sender{
    if (self.tableView.hidden) {
        [self.textView resignFirstResponder];
    }else{
        
    }
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    NSString *messageText = [self.textView.text copy];
    [mixpanel track:@"Send Private Message Did Click" properties:@{@"messageText": messageText}];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    @try {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [super didPressRightButton:sender];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    if (![NSString isStringEmpty:messageModel.messageText]) {
        NCMessageTableViewCell *cell = (NCMessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.userNameLabel.text = messageModel.userName;
        cell.userNameLabel.textColor = [UIColor whiteColor];
        cell.userNameLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.text = messageModel.messageText;
        cell.textMessageLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.delegate = self;
        cell.timeLabel.textColor = [UIColor whiteColor];
        cell.timeLabel.text = messageModel.timestamp.tableViewCellTimeString;
        cell.indexPath = indexPath;
        [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.userSpriteUrl]];
        cell.transform = self.tableView.transform;
        return cell;
    }
    
    NCImageMessageTableViewCell *cell = (NCImageMessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:ImageMessageCellIdentifier];
    cell.nameLabel.text = messageModel.userName;
    cell.backgroundColor = [UIColor clearColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.timeLabel.textColor = [UIColor whiteColor];
    cell.timeLabel.text = messageModel.timestamp.tableViewCellTimeString;
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.userSpriteUrl]];
    [cell.messageImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.messageImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.transform = self.tableView.transform;
    return cell;
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

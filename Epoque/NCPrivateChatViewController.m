//
//  NCPrivateChatViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCPrivateChatViewController.h"
#import "NCReportViewController.h"
#import "NCFireService.h"
#import "NCUploadService.h"
#import "NCMessageTableViewCell.h"
#import "NCImageMessageTableViewCell.h"
#import "PrivateMessageModel.h"
@interface NCPrivateChatViewController ()

@end

@implementation NCPrivateChatViewController{
    NCUploadService *uploadService;
    NCSoundEffect *shoutSound;
    NCSoundEffect *proudSound;
    NCSoundEffect *tableShoutSound;
    NCFireService *fireService;
    BOOL initialAdds;
}

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *ImageMessageCellIdentifier = @"ImageMessageCell";
static NSString *CameraTitle = @"Camera";
static NSString *GalleryTitle = @"Gallery";
static NSString *kBlockUserTitle = @"Block User";
static NSString *kReportUserTitle = @"Report User";
static NSString *kUnblockUserTitle = @"Unblock User";

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
    [self setUpBackButtonWithConversationsDefault];
    initialAdds = YES;
    fireService = [NCFireService sharedInstance];
    uploadService = [NCUploadService sharedInstance];
    shoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"shout.wav"];
    tableShoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    proudSound = [[NCSoundEffect alloc]initWithSoundNamed:@"proud.wav"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
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
    
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    Firebase *messagesRef = [[[[fireService.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:myUserId] childByAppendingPath:@"inbox"] childByAppendingPath:self.regardingUserId];
    
    [messagesRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        initialAdds = NO;
        @strongify(self);
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        [[[[[fireService.rootRef childByAppendingPath:@"user-notification-badges"] childByAppendingPath:myUserId] childByAppendingPath:@"private-messages"] childByAppendingPath:self.regardingUserId] setValue:@(0)];
    }];
    
    [messagesRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        PrivateMessageModel *privateMessageModel = [[PrivateMessageModel alloc]initWithSnapshot:snapshot];
        if ([[NSUserDefaults standardUserDefaults] isUserBlocked:privateMessageModel.senderUserId]) {
            return;
        }
        [self.messages insertObject:privateMessageModel atIndex:0];
        [self.tableView reloadData];
    }];
    
    [messagesRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        PrivateMessageModel *privateMessageModel = [[PrivateMessageModel alloc]initWithSnapshot:snapshot];
        NSString *privateMessageId = privateMessageModel.privateMessageId;
        for (int i = 0; i < self.messages.count; i++) {
            PrivateMessageModel *thisPrivateMessage = [self.messages objectAtIndex:i];
            if ([privateMessageId isEqualToString:thisPrivateMessage.privateMessageId]) {
                [self.messages removeObjectAtIndex:i];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"user_options"] style:UIBarButtonItemStylePlain target:self action:@selector(userOptionsButtonDidClick:)];
}

-(void)userOptionsButtonDidClick:(id)sender{
    [Amplitude logEvent:@"Private Chat User Options Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
    BOOL userIdBlocked = [[NSUserDefaults standardUserDefaults] isUserBlocked:self.regardingUserId];
    UIActionSheet *actionSheet;
    if (userIdBlocked) {
        actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kReportUserTitle, kUnblockUserTitle, nil];
    }else{
        actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kBlockUserTitle otherButtonTitles:kReportUserTitle, nil];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }else{
        [actionSheet showInView:self.view];
    }
}

- (void)didCancelTextEditing:(id)sender
{
    [super didCancelTextEditing:sender];
}

#pragma Send Private Message

-(void)didPressRightButton:(id)sender{
    [proudSound play];
    if (self.tableView.hidden) {
        [self.textView resignFirstResponder];
    }else{
        
    }

    [self sendMessageWithText:self.textView.text messageImageUrl:@""];
    
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

-(void)didPressLeftButton:(id)sender{
    [Amplitude logEvent:@"Private Chat Image Button Did Click"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CameraTitle, GalleryTitle , nil];
    [actionSheet showInView:self.view];
    [super didPressLeftButton:sender];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:CameraTitle] || [title isEqualToString:GalleryTitle]) {
        
        self.imagePicker = [[UIImagePickerController alloc]init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        if ([title isEqualToString:CameraTitle]) {
            [Amplitude logEvent:@"Private Chat Camera Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        if ([title isEqualToString:GalleryTitle]) {
            [Amplitude logEvent:@"Private Chat Gallery Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }else{
        if ([title isEqualToString:kBlockUserTitle]) {
            [Amplitude logEvent:@"User Block Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
            [[NSUserDefaults standardUserDefaults] blockUserWithId:self.regardingUserId];
        }
        if ([title isEqualToString:kUnblockUserTitle]) {
            [Amplitude logEvent:@"User Unblock Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
            [[NSUserDefaults standardUserDefaults] unblockUserId:self.regardingUserId];
        }
        if ([title isEqualToString:kReportUserTitle]){
            [Amplitude logEvent:@"User Report Button Did Click" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
            NCReportViewController *reportViewController = [[NCReportViewController alloc]init];
            reportViewController.regardingUserId = self.regardingUserId;
            reportViewController.regardingUserName = self.regardingUserName;
            reportViewController.regardingUserSpriteUrl = self.regardingUserSpriteUrl;
            [self.navigationController pushRetroViewController:reportViewController];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    @weakify(self);
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [NCLoadingView showInView:self.view withTitleText:@"Uploading Image..."];
    [Amplitude logEvent:@"Upload Image"];
    [[[uploadService uploadImage:chosenImage] doNext:^(NSString *imageUrl) {
        @strongify(self);
        [self sendMessageWithText:@"" messageImageUrl:imageUrl];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [[[UIAlertView alloc]initWithTitle:@"Uh Oh" message:@"We couldn't upload your image" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil]show];
    }];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)sendMessageWithText:(NSString *)messageText messageImageUrl:(NSString *)messageImageUrl{
    UserModel *myUserModel = [NSUserDefaults standardUserDefaults].userModel;
    [Amplitude logEvent:@"Send Private Message Button Did Click" withEventProperties:@{@"messageText": messageText, @"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName}];
    
    NSString *myUserId = myUserModel.userId;
    NSString *otherUserId = self.regardingUserId;
    
    // user-private-messages/{myuserId}/inbox/{regardingUserId}/--childAutoId
    Firebase *otherInbox = [[[[fireService.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:otherUserId] childByAppendingPath:@"inbox"] childByAppendingPath:myUserId];
    
    Firebase *myInbox = [[[[fireService.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:myUserId] childByAppendingPath:@"inbox"] childByAppendingPath:otherUserId];
    
    // conversations
    
    Firebase *otherConversations = [[[[fireService.rootRef childByAppendingPath:@"user-conversations"] childByAppendingPath:otherUserId] childByAppendingPath:@"conversations"] childByAppendingPath:myUserId];
    
    Firebase *myConversations = [[[[fireService.rootRef childByAppendingPath:@"user-conversations"] childByAppendingPath:myUserId] childByAppendingPath:@"conversations"] childByAppendingPath:otherUserId];
    
    Firebase *userPrivateMessagePushBus = [fireService.rootRef childByAppendingPath:@"user-private-messages-push-bus"];
    
    
    NSDictionary *privateMessageJson = @{
                           @"senderUserId": myUserId,
                           @"senderUserName": myUserModel.name,
                           @"senderUserSpriteUrl": myUserModel.spriteUrl,
                           @"messageText": messageText,
                           @"messageImageUrl": messageImageUrl,
                           @"timestamp": [NSDate javascriptTimestampNow]
                           };
    
    NSDictionary *myConversationJson = @{
                                         @"regardingUserId": self.regardingUserId,
                                         @"regardingUserName": self.regardingUserName,
                                         @"regardingUserSpriteUrl": self.regardingUserSpriteUrl,
                                         @"messageText": messageText,
                                         @"messageImageUrl": messageImageUrl,
                                         @"timestamp": [NSDate javascriptTimestampNow]
                                         };
    
    NSDictionary *otherConversationJson = @{
                                         @"regardingUserId": myUserModel.userId,
                                         @"regardingUserName": myUserModel.name,
                                         @"regardingUserSpriteUrl": myUserModel.spriteUrl,
                                         @"messageText": messageText,
                                         @"messageImageUrl": messageImageUrl,
                                         @"timestamp": [NSDate javascriptTimestampNow]
                                         };
    
    
    NSDictionary *pushBusJson = @{
                                  @"senderUserId": myUserModel.userId,
                                  @"senderUserName": myUserModel.name,
                                  @"senderSpriteUrl": myUserModel.spriteUrl,
                                  @"recipientUserId": otherUserId,
                                  @"messageText": messageText,
                                  @"messageImageUrl": messageImageUrl,
                                  @"timestamp": [NSDate javascriptTimestampNow]};
    
    [[myInbox childByAutoId] setValue:privateMessageJson];
    [[otherInbox childByAutoId] setValue:privateMessageJson];
    [otherConversations setValue:otherConversationJson];
    [myConversations setValue:myConversationJson];
    [userPrivateMessagePushBus setValue:pushBusJson];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PrivateMessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    if (![NSString isStringEmpty:messageModel.messageText]) {
        NCMessageTableViewCell *cell = (NCMessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.userNameLabel.text = messageModel.senderUserName;
        cell.userNameLabel.textColor = [UIColor whiteColor];
        cell.userNameLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.text = messageModel.messageText;
        cell.textMessageLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.textColor = [UIColor whiteColor];
        cell.textMessageLabel.delegate = self;
        cell.timeLabel.textColor = [UIColor whiteColor];
        cell.timeLabel.text = messageModel.timestamp.tableViewCellTimeString;
        cell.indexPath = indexPath;
        [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.senderUserSpriteUrl]];
        cell.transform = self.tableView.transform;
        return cell;
    }
    
    NCImageMessageTableViewCell *cell = (NCImageMessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:ImageMessageCellIdentifier];
    cell.nameLabel.text = messageModel.senderUserName;
    cell.backgroundColor = [UIColor clearColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.timeLabel.textColor = [UIColor whiteColor];
    cell.timeLabel.text = messageModel.timestamp.tableViewCellTimeString;
    [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.senderUserSpriteUrl]];
    [cell.messageImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.messageImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.transform = self.tableView.transform;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PrivateMessageModel *privateMessage = [self.messages objectAtIndex:indexPath.row];
        [Amplitude logEvent:@"Deleted Private Chat Message" withEventProperties:@{@"chattingWithUserId": self.regardingUserId, @"chattingWithUserName": self.regardingUserName, @"privateMessageId": privateMessage.privateMessageId, @"messageText": privateMessage.messageText, @"messageImageUrl": privateMessage.messageImageUrl}];
        
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        Firebase *messagesRef = [[[[fireService.rootRef childByAppendingPath:@"user-private-messages"] childByAppendingPath:myUserId] childByAppendingPath:@"inbox"] childByAppendingPath:self.regardingUserId];
        [[messagesRef childByAppendingPath:privateMessage.privateMessageId] removeValue];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  NCWorldChatViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//


#import "NCNavigationController.h"
#import "NCWorldChatViewController.h"
#import "NCWorldDetailViewController.h"
#import "NCImageMessageTableViewCell.h"
#import "NCMessageTableViewCell.h"
#import "NCFireService.h"
#import "NCUploadService.h"
#import "NCWorldService.h"
#import "MessageModel.h"
#import "NCMapViewController.h"
#import "UserAnnotation.h"
#import "UserAnnotationView.h"
#import "AppDelegate.h"
#import "NCUserDetailViewController.h"
#import "NCPrivateChatViewController.h"
@interface NCWorldChatViewController ()

@end

@implementation NCWorldChatViewController{
    NCFireService *fireService;
    NCWorldService *worldService;
    NCUploadService *uploadService;
    NCSoundEffect *shoutSound;
    NCSoundEffect *tableShoutSound;
    NCSoundEffect *proudSound;
    NCSoundEffect *sentSound;
    NSMutableDictionary *userAnnotations;
    UIBarButtonItem *mapToggleBarButton;
    UIBarButtonItem *worldDetailBarButton;
    Mixpanel *mixpanel;
    __block BOOL initialAdds;
    FirebaseHandle messageAddedHandle;
    FirebaseHandle messageRemovedHandle;
    FirebaseHandle shoutsAddedHandle;
    FirebaseHandle shoutsChangedHandle;
    FirebaseHandle worldPushBusHandle;
    FirebaseHandle worldValueHandle;
    Firebase *worldValueRef;
    FQuery *messageAddedQuery;
    FQuery *messageRemovedQuery;
    Firebase *worldShoutsRef;
    Firebase *worldPushBusRef;
    WorldModel *worldModel;
}

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *ImageMessageCellIdentifier = @"ImageMessageCell";
static NSString *CameraTitle = @"Camera";
static NSString *GalleryTitle = @"Gallery";

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        RACSignal *viewDidLoad = [[self rac_signalForSelector:@selector(viewDidLoad)] map:^id(id value) {
           return @"viewDidLoad";
        }];
        RACSignal *worldIdSignal = [RACObserve(self, worldId) map:^id(id value) {
            return @"worldModelChanged";
        }];
        RACSignal *latest = [RACSignal combineLatest:@[worldIdSignal, viewDidLoad] reduce:^id{
            return @"latest";
        }];
        [self rac_liftSelector:@selector(setUpListeners:) withSignals:latest, nil];
    }
    return self;
}

+(id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

-(void)setUpListeners:(id)sender{
    if (self.mapView != nil) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    self.messages = [NSMutableArray array];
    mixpanel = [Mixpanel sharedInstance];
    uploadService = [NCUploadService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    userAnnotations = [NSMutableDictionary dictionary];
    shoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"shout.wav"];
    tableShoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    proudSound = [[NCSoundEffect alloc]initWithSoundNamed:@"proud.wav"];
    sentSound =  [[NCSoundEffect alloc]initWithSoundNamed:@"sent.wav"];
    initialAdds = YES;
    userAnnotations = [NSMutableDictionary dictionary];
    @weakify(self);
    
    
    if (worldValueRef) {
        [worldValueRef removeObserverWithHandle:worldValueHandle];
    }
    worldValueRef = [[fireService worldsRef] childByAppendingPath:self.worldId];
    [worldValueRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        worldModel = [[WorldModel alloc] initWithSnapshot:snapshot];
        self.title = worldModel.name;
    }];
    
    if (messageAddedQuery) {
        [messageAddedQuery removeObserverWithHandle:messageAddedHandle];
    }
    messageAddedQuery = [[[fireService worldMessagesRef:self.worldId] queryOrderedByChild:@"timestamp"] queryLimitedToLast:300];
    messageAddedHandle = [messageAddedQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        MessageModel *messageModel = [[MessageModel alloc]initWithSnapshot:snapshot];
        [self.messages insertObject:messageModel atIndex:0];
        [self.tableView reloadData];
    }];
    

    [[[fireService worldMessagesRef:self.worldId] queryLimitedToLast:1] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.tableView reloadData];
        initialAdds = NO;
    }];
    
    if (worldShoutsRef) {
        [worldShoutsRef removeObserverWithHandle:shoutsAddedHandle];
    }
    worldShoutsRef = [fireService worldShoutsRef:self.worldId];
    shoutsAddedHandle = [worldShoutsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        UserAnnotation *userAnno = [[UserAnnotation alloc]initWithSnapshot:snapshot];
        userAnnotations[snapshot.key] = userAnno;
        [self.mapView addAnnotation:userAnno];
        if ([userAnno.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
            [self.mapView zoomToLocation:userAnno.coordinate withSpan:0.05];
        }
    }];
    
    if (worldShoutsRef) {
        [worldShoutsRef removeObserverWithHandle:shoutsChangedHandle];
    }
    shoutsChangedHandle = [worldShoutsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        UserAnnotation *userAnno = [userAnnotations objectForKey:snapshot.key];
        if (userAnno) {
            [userAnno upsertFromSnapshot:snapshot];
            UserAnnotationView *userAnnoView =  (UserAnnotationView *) [self.mapView viewForAnnotation:userAnno];
            if (userAnnoView) {
                userAnnoView.userAnnotation = userAnno;
                [userAnnoView animateRings];
            }
        }
        
    }];
    
    if (worldPushBusRef) {
        [worldPushBusRef removeObserverWithHandle:worldPushBusHandle];
    }
    worldPushBusRef = [fireService worldPushBusRef:self.worldId];
    worldPushBusHandle = [worldPushBusRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.value);
        if ([NSUserDefaults standardUserDefaults].worldMapEnabled) {
            [shoutSound play];
            
        }else{
            [tableShoutSound play];
        }
    }];
    
    if (messageRemovedQuery) {
        [messageRemovedQuery removeObserverWithHandle:messageRemovedHandle];
    }

    messageRemovedQuery = [fireService worldMessagesRef:self.worldId];
    messageRemovedHandle = [messageRemovedQuery observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value == [NSNull null]) {
            return;
        }
        NSString *messageId = snapshot.key;
        for (int i = 0; i < self.messages.count; i++) {
            MessageModel *thisMessageModel = [self.messages objectAtIndex:i];
            if ([messageId isEqualToString:thisMessageModel.messageId]) {
                [self.messages removeObjectAtIndex:i];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButtonWithWorldsDefault];
    self.mapView = ((AppDelegate *)[UIApplication sharedApplication].delegate).mapView;
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.frame = self.view.bounds;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.mapView belowSubview:self.tableView];
    UITapGestureRecognizer *mapTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapViewDidTap:)];
    [self.mapView addGestureRecognizer:mapTapGesture];
    self.mapView.delegate = self;
    
    
    UIColor *backgroundColor = [UIColor colorWithRed:44.0/255.0 green:57.0/255 blue:76.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = backgroundColor;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purple_stars_background.jpg"]];
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    self.view.backgroundColor = backgroundColor;
    
    fireService = [NCFireService sharedInstance];
    UIImage *mapIconImage = [UIImage imageNamed:@"map_icon"];
    UIImage *worldDetailIconImage = [UIImage imageNamed:@"saturn_icon"];
    mapToggleBarButton = [[UIBarButtonItem alloc]initWithImage:mapIconImage style:UIBarButtonItemStylePlain target:self action:@selector(mapButtonDidClick:)];
    worldDetailBarButton = [[UIBarButtonItem alloc]initWithImage:worldDetailIconImage style:UIBarButtonItemStylePlain target:self action:@selector(worldDetailDidClick:)];
    self.navigationItem.rightBarButtonItems = @[mapToggleBarButton, worldDetailBarButton];
    
    self.bounces = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
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
    self.tableView.hidden = [NSUserDefaults standardUserDefaults].worldMapEnabled;
    
    [RACObserve(self.tableView, hidden) subscribeNext:^(id x) {
        BOOL isHidden = [x boolValue];
        [[NSUserDefaults standardUserDefaults] setWorldMapEnabled:isHidden];
        if (isHidden) {
            [mapToggleBarButton setImage:[UIImage imageNamed:@"chat_icon"]];
        }else{
            [mapToggleBarButton setImage:[UIImage imageNamed:@"map_icon"]];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)pageMoreMessages:(NSDate *)timestamp{
    NSNumber *timestampNumber = [NSDate javascriptTimestampFromDate:timestamp];
    [[[[[fireService worldMessagesRef:self.worldId] queryOrderedByChild:@"timestamp"] queryStartingAtValue:timestampNumber] queryLimitedToLast:30] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for (id key in snapshot.value) {
            id value = [snapshot.value objectForKey:key];
            MessageModel *messageModel = [[MessageModel alloc]initWithDictionary:value error:nil];
            messageModel.messageId = [key copy];
            [self.messages insertObject:messageModel atIndex:0];
        }
    }];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if ([messageModel.userId isEqualToString:myUserId]) {
        return YES;
    }
    if ([[NSUserDefaults standardUserDefaults].userModel.role isEqualToString:@"admin"]) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
        [[[fireService worldMessagesRef:self.worldId] childByAppendingPath:messageModel.messageId] removeValue];
    }
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
    
    
    [cell.messageImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.messageImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.messageImageView.alpha = 1;
        
        if (cacheType == SDImageCacheTypeNone) {
            cell.messageImageView.alpha = 0;
            [UIView animateWithDuration:0.10 animations:^{
                cell.messageImageView.alpha = 1;
            }];
        }
        
    }];
    cell.transform = self.tableView.transform;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [mixpanel track:@"Send Shout Did Click" properties:@{@"messageText": messageText}];
    [[fireService submitWorldMessage:self.worldId myUserId:userModel.userId mySpriteUrl:userModel.spriteUrl myName:userModel.name myUserImageUrl:userModel.imageUrl text:messageText imageUrl:@""] subscribeNext:^(id x) {

    } error:^(NSError *error) {
        NSLog(@"Error submitting chat message %@", error);
    }];
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
    [mixpanel track:@"Shout Image Button Did Click"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CameraTitle, GalleryTitle , nil];
    [actionSheet showInView:self.view];
    [super didPressLeftButton:sender];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    if ([title isEqualToString:CameraTitle]) {
        [mixpanel track:@"Camera Button Did Click"];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    if ([title isEqualToString:GalleryTitle]) {
        [mixpanel track:@"Gallery Button Did Click"];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    @weakify(self);
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [NCLoadingView showInView:self.view withTitleText:@"Uploading Image..."];
    [mixpanel timeEvent:@"Upload Image"];
    [[[uploadService uploadImage:chosenImage] flattenMap:^RACStream *(id value) {
        @strongify(self);
        [mixpanel track:@"Upload Image"];
        UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
        return [fireService submitWorldMessage:self.worldId myUserId:userModel.userId mySpriteUrl:userModel.spriteUrl myName:userModel.name myUserImageUrl:userModel.imageUrl text:@"" imageUrl:value];
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


-(void)mapButtonDidClick:(id)sender{
    BOOL tableIsHidden = self.tableView.hidden;
    self.tableView.hidden = !tableIsHidden;
    
    [self.textView becomeFirstResponder];
}

-(void)mapViewDidTap:(id)sender{
    [self.textView resignFirstResponder];
}

-(void)worldDetailDidClick:(id)sender{
    NCWorldDetailViewController *detailViewController = [[NCWorldDetailViewController alloc]init];
    detailViewController.worldId = self.worldId;
    [self.navigationController pushRetroViewController:detailViewController];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[UserAnnotation class]]) {
        UserAnnotation *userAnno = (UserAnnotation *)annotation;
        UserAnnotationView *userAnnotationView = (UserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kNCUserAnnotationIdentifier];
        if (userAnnotationView == nil) {
            userAnnotationView = [[UserAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kNCUserAnnotationIdentifier];
        }
        userAnnotationView.annotation = annotation;
        userAnnotationView.userAnnotation = userAnno;
        return userAnnotationView;
    }
    return nil;
};

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [mapView deselectAnnotation:view.annotation animated:YES];
    if ([view isKindOfClass:[UserAnnotationView class]]) {
        UserAnnotation *userAnnotation = ((UserAnnotationView *)view).userAnnotation;
        [self goToIndividualChatMessage:userAnnotation.userId userName:userAnnotation.userName spriteUrl:userAnnotation.userSpriteUrl messageText:userAnnotation.messageText messageImageUrl:userAnnotation.messageImageUrl timestamp:userAnnotation.timestamp];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    if (messageModel) {
        [self goToIndividualChatMessage:messageModel.userId userName:messageModel.userName spriteUrl:messageModel.userSpriteUrl messageText:messageModel.messageText messageImageUrl:messageModel.messageImageUrl timestamp:messageModel.timestamp];
    }
}


-(void)goToIndividualChatMessage:(NSString *)userId userName:(NSString *)userName spriteUrl:(NSString *)spriteUrl messageText:(NSString *)messageText messageImageUrl:(NSString *)messageImageUrl timestamp:(NSDate *)timestamp{
    if ([userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
        NSString *message = [NSString stringWithFormat:@"Hey %@ this is you! It's really you! I'm so proud of you.", userName];
        [CSNotificationView showInViewController:self tintColor:[UIColor colorWithHexString:@"#26856A"] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
        [proudSound play];
        return;
    }
    [mixpanel track:@"Go To Private Chat" properties:@{@"userName": userName, @"userId": userId, @"worldName": worldModel.name, @"worldId": self.worldId}];
    NCPrivateChatViewController *privateChatViewController = [[NCPrivateChatViewController alloc]init];
    privateChatViewController.regardingUserId = userId;
    privateChatViewController.regardingUserName = userName,
    privateChatViewController.regardingUserSpriteUrl = spriteUrl;
    [self.navigationController pushRetroViewController:privateChatViewController];
}

@end

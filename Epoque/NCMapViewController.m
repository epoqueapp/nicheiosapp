//
//  NCWorldMapViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController.h"
#import "NCMapViewController+LayoutSetup.h"
#import "NCMapViewController+Utilities.h"
#import "NCFireService.h"
#import "NCMessageTableViewCell.h"
@interface NCMapViewController ()

@end

@implementation NCMapViewController{
    FQuery *worldShouts;
    FQuery *worldMessages;
    FQuery *lastWorldMessage;
    Firebase *worldRef;
    Firebase *worldListeners;
}

-(id)initWithWorldId:(NSString *)worldId{
    self = [super init];
    if (self) {
        self.worldId = [worldId copy];
        if (worldId == nil) {
            self.worldId = [kOpenWorldTitle copy];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userAnnotations = [NSMutableDictionary dictionary];
    self.messages = [NSMutableArray array];
    
    NSDate *hoursAgo12 = [[NSDate date] dateByAddingTimeInterval:-3600*12];
    
    worldRef =    [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"] childByAppendingPath:self.worldId];
    worldShouts = [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] queryOrderedByChild:@"timestamp"] queryStartingAtValue:[NSDate javascriptTimestampFromDate:hoursAgo12]];
    worldMessages = [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-messages"] childByAppendingPath:self.worldId] queryOrderedByChild:@"timestamp"] queryLimitedToLast:80];
    lastWorldMessage = [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-messages"] childByAppendingPath:self.worldId] queryOrderedByChild:@"timestamp"] queryLimitedToLast:1];
    
    worldListeners = [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-listeners"] childByAppendingPath:self.worldId];
    
    
    self.mapShoutSoundEffect = [[NCSoundEffect alloc] initWithSoundNamed:@"shout.wav"];
    self.tableShoutSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    self.centerSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"proud.wav"];
    
    
    [self setUpTextView:self];
    [self setUpMapView:self];
    [self setUpChatPreviewView:self];
    [self setUpWorldHolder:self];
    [self setUpLocationUpdateButton:self];
    [self setUpCenterMeButton:self];
    [self setUpRemoveMeButton:self];
    [self setUpBellButton:self];
    [self setUpMenuButton:self];
    [self setUpSearchButton:self];
    [self setUpLeftButton:self];
    [self setUpTableButton:self];
    [self setUpMapButton:self];
    [self setUpTableView:self];
    [self setUpLayout:self];

    
    self.lastKnownLocation = [[CLLocation alloc]initWithLatitude:0 longitude:0];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    @weakify(self);
    [worldShouts observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        UserAnnotation *userAnnotation = [[UserAnnotation alloc]initWithSnapshot:snapshot];
        [self.userAnnotations setObject:userAnnotation forKey:userAnnotation.userId];
        [self.mapView addAnnotation:userAnnotation];
        if ([userAnnotation.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
            [self.mapView zoomToLocation:userAnnotation.coordinate withSpan:0.05];
        }
    }];
    
    [worldShouts observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        UserAnnotation *userAnnotation = [self.userAnnotations objectForKey:snapshot.key];
        if (userAnnotation ==nil) {
            return;
        }
        [userAnnotation upsertFromSnapshot:snapshot];
        UserAnnotationView *userAnnotationView = (UserAnnotationView*)[self.mapView viewForAnnotation:userAnnotation];
        if (userAnnotationView) {
            userAnnotationView.userAnnotation = userAnnotation;
        }
    }];
    
    [worldShouts observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        NSString *userId = snapshot.key;
        UserAnnotation *userAnnotation = [self.userAnnotations objectForKey:userId];
        if (userAnnotation ==nil) {
            return;
        }
        [self.mapView removeAnnotation:userAnnotation];
        [self.userAnnotations removeObjectForKey:userId];
    }];
    
    //Table Elements Visibility
    RACSignal *mapEnabled = [[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCWorldMapEnabled] map:^id(id value) {
        return @([value boolValue]);
    }];
    
    RAC(self.tableView, hidden) = mapEnabled;
    RAC(self.mapButton, hidden) = mapEnabled;
    
    [RACObserve(self, isListening) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            [self.bellButton setImage:[UIImage imageNamed:@"bell_button_ringing"] forState:UIControlStateNormal];
        }else{
            [self.bellButton setImage:[UIImage imageNamed:@"bell_button_not_ringing"] forState:UIControlStateNormal];
        }
    }];
    
    //TABLE EVENTS
    __block BOOL isInitialAdds = YES;
    [worldMessages observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        MessageModel *messageModel = [[MessageModel alloc]initWithSnapshot:snapshot];
        [self.messages insertObject:messageModel atIndex:0];
        if (!isInitialAdds) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }];
    
    [worldMessages observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [self.tableView reloadData];
        isInitialAdds = NO;
    }];
    
    [worldMessages observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        NSString *messageId = snapshot.key;
        [self.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MessageModel *messageModel = obj;
            if ([messageModel.messageId isEqualToString:messageId]) {
                [self.messages removeObject:obj];
                MessageModel *newMessageModel = [[MessageModel alloc]initWithSnapshot:snapshot];
                [self.messages insertObject:newMessageModel atIndex:idx];
                [self.tableView reloadRowsAtIndexPaths :@[[NSIndexPath indexPathForRow:idx inSection:0]]  withRowAnimation:UITableViewRowAnimationAutomatic];
                *stop = YES;
            }
        }];
    }];
    
    [worldMessages observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        NSString *messageId = snapshot.key;
        [self.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MessageModel *messageModel = obj;
            if ([messageModel.messageId isEqualToString:messageId]) {
                [self.messages removeObject:obj];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]  withRowAnimation:UITableViewRowAnimationAutomatic];
                *stop = YES;
            }
        }];
    }];
    
    //chat preview message
    __block BOOL isInitialLastMessage = YES;
    [lastWorldMessage observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if(snapshot.value == [NSNull null]){
            return;
        }
        
        if (isInitialLastMessage == NO && self.tableView.hidden) {
            [self.mapShoutSoundEffect play];
        }
        if (isInitialLastMessage == NO && !self.tableView.hidden) {
            [self.tableShoutSoundEffect play];
        }
        
        MessageModel *messageModel = [[MessageModel alloc] initWithSnapshot:snapshot];
        
        [self setChatPreviewViewWithUserId:messageModel.userId spriteUrl:messageModel.userSpriteUrl name:messageModel.userName messageText:messageModel.messageText messageImageUrl:messageModel.messageImageUrl timestamp:messageModel.timestamp backgroundColor:[UIColor darkGrayColor]];
        
        self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        [UIView animateWithDuration:0.10 animations:^{
            self.chatPreviewView.backgroundColor = [UIColor whiteColor];
        }];
        [UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        } completion:^(BOOL finished) {
            self.chatPreviewView.backgroundColor = [UIColor darkGrayColor];
        }];
        
        UserAnnotation *userAnnotation = [self.userAnnotations objectForKey:messageModel.userId];
        if(userAnnotation){
            UserAnnotationView *userAnnotationView = (UserAnnotationView*)[self.mapView viewForAnnotation:userAnnotation];
            if (userAnnotationView && !isInitialLastMessage) {
                [userAnnotationView animateRings];
            }
        }
        isInitialLastMessage = NO;
    }];
    

    [NCLoadingView showInView:self.view];
    self.worldHolder.alpha = 0;
    [worldRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        self.worldModel = worldModel;
        self.worldNameLabel.text = worldModel.name;
        [self.worldImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
        [UIView animateWithDuration:1.0 animations:^{
            self.worldHolder.alpha = 1;
        }];
    }];
    
    [worldListeners observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value != [NSNull null]) {
            NSDictionary *values = snapshot.value;
            NSArray *userIds = [values allKeys];
            NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
            self.isListening = [userIds containsObject:myUserId];
        }else{
            self.isListening = NO;
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    NCMessageTableViewCell *cell = (NCMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier];
    cell.indexPath = indexPath;
    [cell setMessageModel:messageModel];
    cell.delegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    UserModel *myUserModel = [NSUserDefaults standardUserDefaults].userModel;
    return [myUserModel.role isEqualToString:@"admin"] || [messageModel.userId isEqualToString:myUserModel.userId];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
        [[worldMessages.ref childByAppendingPath:messageModel.messageId] removeValue];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

-(void)tappedSpriteImageView:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    [Amplitude logEvent:@"Message Sprite Did Tap" withEventProperties:@{@"worldId": self.worldId, @"messageId": messageModel.messageId}];
    NSString *userId = messageModel.userId;
    [[NSUserDefaults standardUserDefaults] setWorldMapEnabled:YES];
    UserAnnotation *userAnno = [self.userAnnotations objectForKey:userId];
    if (userAnno) {
        [self.mapView zoomToLocation:userAnno.coordinate withSpan:0.00015];
        UserAnnotationView *userAnnotationView = (UserAnnotationView *)[self.mapView viewForAnnotation:userAnno];
        if (userAnnotationView) {
            self.mapView.centerCoordinate = userAnno.coordinate;
            [userAnnotationView animateCenterRing];
        }
    }
}

-(void)tappedUserNameLabel:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    if ([messageModel.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
        return;
    }
    [Amplitude logEvent:@"Message Name Did Tap" withEventProperties:@{@"worldId": self.worldId, @"messageId": messageModel.messageId, @"userId": messageModel.userId}];
    self.userIdToBlock = [messageModel.userId copy];
    self.userIdToReport = [messageModel.userId copy];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kBlockUserTitle otherButtonTitles:kReportUserTitle, nil];
    [actionSheet showInView:self.view];
}

-(void)tappedAttachmentImageView:(NSIndexPath *)indexPath image:(UIImage *)image{
    NCAttachmentPhoto *attachmentPhoto = [[NCAttachmentPhoto alloc]init];
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    attachmentPhoto.image = image;
    attachmentPhoto.attributedCaptionTitle = [[NSAttributedString alloc]initWithString:messageModel.userName];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[attachmentPhoto]];
    [self presentViewController:photosViewController animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)clearMap{
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    [worldShouts removeAllObservers];
    [worldMessages removeAllObservers];
    [lastWorldMessage removeAllObservers];
    [worldRef removeAllObservers];
    [worldListeners removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)sendMessage:(SendMessageModel *)sendMessageModel{
    sendMessageModel.worldId = [self.worldId copy];
    [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-messages"] childByAppendingPath:self.worldId] childByAutoId] setValue:[sendMessageModel toDictionary]];
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-shouts"] childByAppendingPath:self.worldId] childByAppendingPath:userId] setValue:[sendMessageModel toDictionary]];
    [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-push-bus"] setValue:[sendMessageModel toDictionary]];
    [self attemptToScrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

-(void)attemptToScrollToIndexPath:(NSIndexPath *)indexPath{
    @try {
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            UIColor *originalBackgroundColor = [cell.backgroundColor copy];
            
            
            [UIView animateWithDuration:1.0 animations:^{
                cell.backgroundColor = [UIColor whiteColor];
            }];
            
            [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
                cell.backgroundColor = originalBackgroundColor;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

@end

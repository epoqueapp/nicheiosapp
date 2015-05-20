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
#import "NCMessageTableViewCell.h"
#import "NCFireService.h"
#import "NCUploadService.h"
#import "MessageModel.h"
#import "NCMapViewController.h"
#import "UserAnnotation.h"
#import "UserAnnotationView.h"
@interface NCWorldChatViewController ()

@end

@implementation NCWorldChatViewController{
    NCFireService *fireService;
    NCUploadService *uploadService;
    NCSoundEffect *shoutSound;
    NCSoundEffect *tableShoutSound;
    NCSoundEffect *proudSound;
    NCSoundEffect *locationUpdateSound;
    NCSoundEffect *sentSound;
    NSMutableDictionary *userAnnotations;
    UIBarButtonItem *mapToggleBarButton;
    UIBarButtonItem *worldDetailBarButton;
    __block BOOL initialAdds;
    FirebaseHandle messageAddedHandle;
    FirebaseHandle messageChangedHandle;
    FirebaseHandle messageRemovedHandle;
    FirebaseHandle shoutsAddedHandle;
    FirebaseHandle shoutsChangedHandle;
    FirebaseHandle worldPushBusHandle;
    FirebaseHandle worldValueHandle;
    Firebase *worldValueRef;
    FQuery *messageAddedQuery;
    FQuery *messageChangedQuery;
    FQuery *messageRemovedQuery;
    Firebase *worldShoutsRef;
    Firebase *worldPushBusRef;
    WorldModel *worldModel;
    UIImage *heartGreyImage;
    UIImage *heartRedImage;
    NSString *userIdToBlock;
    NSString *userIdToReport;
    CLLocationManager *locationManager;
}

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *CameraTitle = @"Camera";
static NSString *GalleryTitle = @"Gallery";
static NSString *BlockUserTitle = @"Block User";
static NSString *ReportUserTitle = @"Report User";
static NSString *ConfirmBlockUserTitle = @"Yes, Block";

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
        [self rac_liftSelector:@selector(clearNotificationBadgesForThisWorld:) withSignals:latest, nil];
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
    [self.tableView reloadData];
    uploadService = [NCUploadService sharedInstance];
    userAnnotations = [NSMutableDictionary dictionary];
    shoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"shout.wav"];
    tableShoutSound = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    proudSound = [[NCSoundEffect alloc]initWithSoundNamed:@"proud.wav"];
    sentSound =  [[NCSoundEffect alloc]initWithSoundNamed:@"sent.wav"];
    locationUpdateSound = [[NCSoundEffect alloc]initWithSoundNamed:@"location_update.wav"];
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
        [messageAddedQuery removeObserverWithHandle:messageChangedHandle];
    }
    messageAddedQuery = [[[fireService worldMessagesRef:self.worldId] queryOrderedByChild:@"timestamp"] queryLimitedToLast:50];
    messageAddedHandle = [messageAddedQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        MessageModel *messageModel = [[MessageModel alloc]initWithSnapshot:snapshot];
        if ([[NSUserDefaults standardUserDefaults] isUserBlocked:messageModel.userId]) {
            return;
        }
        [self.messages insertObject:messageModel atIndex:0];
        if(!initialAdds){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPathsWithEpoqueAnimation:@[indexPath]];
            
        }
    }];
    
    messageChangedHandle = [messageAddedQuery observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        MessageModel *changedMessageModel = [[MessageModel alloc]initWithSnapshot:snapshot];
        for (int i = 0; i < self.messages.count; i++) {
            MessageModel *thisMessageModel = [self.messages objectAtIndex:i];
            if ([thisMessageModel.messageId isEqualToString:changedMessageModel.messageId]) {
                [self.messages replaceObjectAtIndex:i withObject:changedMessageModel];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }];
    
    [[fireService worldMessagesRef:self.worldId] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [self.tableView reloadData];
        initialAdds = NO;
    }];
    
    if (worldShoutsRef) {
        [worldShoutsRef removeObserverWithHandle:shoutsAddedHandle];
    }
    worldShoutsRef = [fireService worldShoutsRef:self.worldId];
    shoutsAddedHandle = [worldShoutsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        NSDate *timestamp = [NSDate dateFromJavascriptTimestamp:[snapshot.value objectForKey:@"timestamp"]];
        if ([timestamp isAncient]) {
            return;
        }
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
            
            NSString *originalMessageText = [userAnno.messageText copy];
            NSString *originalImageUrl = [userAnno.messageImageUrl copy];
            NSString *newMessageText = [snapshot.value objectForKey:@"messageText"];
            NSString *newMessageImageUrl = [snapshot.value objectForKey:@"messageImageUrl"];

            
            [userAnno upsertFromSnapshot:snapshot];
            UserAnnotationView *userAnnoView =  (UserAnnotationView *) [self.mapView viewForAnnotation:userAnno];
            if (userAnnoView) {
                userAnnoView.userAnnotation = userAnno;
            }
            if (![originalImageUrl isEqualToString:newMessageImageUrl]){
                
            }
            if(![originalMessageText isEqualToString:newMessageText]) {
                [self animateRingsForAnnotation:userAnno];
            }
        }
        else{
            userAnno = [[UserAnnotation alloc]initWithSnapshot:snapshot];
            userAnnotations[snapshot.key] = userAnno;
            [self.mapView addAnnotation:userAnno];
            if ([userAnno.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
                [self.mapView zoomToLocation:userAnno.coordinate withSpan:0.05];
            }
            [self animateRingsForAnnotation:userAnno];
        }
    }];
    if (worldPushBusRef) {
        [worldPushBusRef removeObserverWithHandle:worldPushBusHandle];
    }
    worldPushBusRef = [fireService worldPushBusRef:self.worldId];
    worldPushBusHandle = [worldPushBusRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
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
        if (snapshot.value == [NSNull null]) {
            return;
        }
    }];
    
    [self.view setNeedsDisplay];
}

-(void)animateRingsForAnnotation:(UserAnnotation *)userAnnotation{
    UserAnnotationView *userAnnoView =  (UserAnnotationView *) [self.mapView viewForAnnotation:userAnnotation];
    if (userAnnoView) {
        [userAnnoView animateRings];
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButtonWithWorldsDefault];
    self.mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.mapView belowSubview:self.tableView];
    UITapGestureRecognizer *mapTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapViewDidTap:)];
    [self.mapView addGestureRecognizer:mapTapGesture];
    self.mapView.delegate = self;
    
    self.emblemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.emblemImageView.image = [UIImage imageNamed:@"image_placholder"];
    [self.view addSubview:self.emblemImageView];
    
    heartGreyImage = [UIImage imageNamed:@"heart_sprite_grey"];
    heartRedImage = [UIImage imageNamed:@"heart_sprite_color"];
    
    self.centerMeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    [self.centerMeButton setImage:[UIImage imageNamed:@"center_me_button"] forState:UIControlStateNormal];
    [self.centerMeButton addTarget:self action:@selector(centerMeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.centerMeButton];
    
    self.updateLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, 30, 30)];
    [self.updateLocationButton setImage:[UIImage imageNamed:@"locate_me_button_off"] forState:UIControlStateNormal];
    [self.updateLocationButton addTarget:self action:@selector(updateLocationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.updateLocationButton];
    
    UIColor *backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = backgroundColor;
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stars.jpg"]];
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempImageView.alpha = 0.5;
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
    self.inverted = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[NCMessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.counterStyle = SLKCounterStyleNone;
    self.textInputbar.rightButton.titleLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:18.0];
    self.textInputbar.textView.font = [UIFont fontWithName:kTrocchiBoldFontName size:14.0];
    self.textInputbar.textView.backgroundColor = [UIColor blackColor];
    self.textInputbar.textView.textColor = [UIColor whiteColor];
    self.textInputbar.textView.keyboardAppearance = UIKeyboardAppearanceDark;
    self.textInputbar.textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textInputbar.backgroundColor = [UIColor blackColor];
    [self.rightButton setTitle:NSLocalizedString(@"SHOUT", nil) forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
    self.tableView.hidden = [NSUserDefaults standardUserDefaults].worldMapEnabled;
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    @weakify(self);
    [RACObserve(self.tableView, hidden) subscribeNext:^(id x) {
        @strongify(self);
        BOOL isHidden = [x boolValue];
        [[NSUserDefaults standardUserDefaults] setWorldMapEnabled:isHidden];
        if (isHidden) {
            [mapToggleBarButton setImage:[UIImage imageNamed:@"chat_icon"]];
            self.centerMeButton.hidden = NO;
            self.updateLocationButton.hidden = NO;
        }else{
            [mapToggleBarButton setImage:[UIImage imageNamed:@"map_icon"]];
            self.centerMeButton.hidden = YES;
            self.updateLocationButton.hidden = YES;
        }
    }];

    
    self.isAutoLocationUpdate = YES;
    [RACObserve(self, isAutoLocationUpdate) subscribeNext:^(id x) {
        @strongify(self);
        BOOL isOn = [x boolValue];
        if (isOn) {
            [self.updateLocationButton setImage:[UIImage imageNamed:@"locate_me_button"] forState:UIControlStateNormal];
        }else{
            [self.updateLocationButton setImage:[UIImage imageNamed:@"locate_me_button_off"] forState:UIControlStateNormal];
        }
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(jiggleRandomUserAnnotation:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (self.isAutoLocationUpdate == NO) {
        return;
    }
    CLLocation *location = [locations objectAtIndex:0];
    self.lastKnownLocation = location;
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    float obscurity = [NSUserDefaults standardUserDefaults].obscurity;
    NSArray *geoJson = [location toGeoJsonWthObscurity:obscurity];
    [[[[fireService worldShoutsRef:self.worldId] childByAppendingPath:myUserId] childByAppendingPath:@"geo"] setValue:geoJson];
    [[[[fireService worldShoutsRef:self.worldId] childByAppendingPath:myUserId] childByAppendingPath:@"timestamp"] setValue:kFirebaseServerValueTimestamp];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    NCMessageTableViewCell *cell = (NCMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    cell.indexPath = indexPath;
    [cell setMessageModel:messageModel];
    cell.delegate = self;
    return cell;
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url];
}

-(void)tappedSpriteImageView:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    [Amplitude logEvent:@"Message Sprite Did Tap" withEventProperties:@{@"worldId": self.worldId, @"messageId": messageModel.messageId}];
    NSString *userId = messageModel.userId;
    self.tableView.hidden = !self.tableView.hidden;
    UserAnnotation *userAnno = [userAnnotations objectForKey:userId];
    if (userAnno) {
        [self.mapView zoomToLocation:userAnno.coordinate withSpan:0.00015];
    }
}

-(void)tappedUserNameLabel:(NSIndexPath *)indexPath{
    MessageModel *messageModel = [self.messages objectAtIndex:indexPath.row];
    if ([messageModel.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
        return;
    }
    [Amplitude logEvent:@"Message Name Did Tap" withEventProperties:@{@"worldId": self.worldId, @"messageId": messageModel.messageId, @"userId": messageModel.userId}];
    userIdToBlock = [messageModel.userId copy];
    userIdToReport = [messageModel.userId copy];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:BlockUserTitle otherButtonTitles:ReportUserTitle, nil];
    [actionSheet showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didCommitTextEditing:(id)sender
{
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    [super didCancelTextEditing:sender];
    
}

-(void)didPressRightButton:(id)sender{
    if (self.tableView.hidden) {
        [self.textView resignFirstResponder];
    }
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    NSString *messageText = [self.textView.text copy];
    [Amplitude logEvent:@"Send Shout Did Click" withEventProperties:@{@"messageText": messageText}];
    BOOL isObscuring = [[NSUserDefaults standardUserDefaults] isObscuring];
    [[fireService submitWorldMessage:self.worldId myUserId:userModel.userId mySpriteUrl:userModel.spriteUrl myName:userModel.name myUserImageUrl:userModel.imageUrl text:messageText imageUrl:@"" isObscuring:isObscuring location:self.lastKnownLocation] subscribeNext:^(id x) {

    } error:^(NSError *error) {
        NSLog(@"Error submitting chat message %@", error);
    }];
    [super didPressRightButton:sender];
    [self scrollToTop];
}

-(void)didPressLeftButton:(id)sender{
    [Amplitude logEvent:@"Shout Image Button Did Click"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CameraTitle, GalleryTitle , nil];
    [actionSheet showInView:self.view];
    [super didPressLeftButton:sender];
}

-(void)scrollToTop{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    if ([title isEqualToString:BlockUserTitle]) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:ConfirmBlockUserTitle, nil]show];
    }
    if ([title isEqualToString:ReportUserTitle]) {
        NSString *message = @"Thank you we've been notified of this user. Good looking out!";
        [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
        [Amplitude logEvent:@"Reported User" withEventProperties:@{@"userId": userIdToReport}];
    }
    if ([title isEqualToString:CameraTitle]) {
        [Amplitude logEvent:@"World Chat Camera Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
    if ([title isEqualToString:GalleryTitle]) {
        [Amplitude logEvent:@"World Chat Gallery Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:ConfirmBlockUserTitle]) {
        [[NSUserDefaults standardUserDefaults] blockUserWithId:userIdToBlock];
        NSString *message = @"You will not receive any more messages from this user";
        [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    @weakify(self);
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [NCLoadingView showInView:self.view withTitleText:@"Uploading Image..."];
    BOOL isObscuring = [[NSUserDefaults standardUserDefaults] isObscuring];
    [[[[uploadService uploadImage:chosenImage] deliverOnMainThread] flattenMap:^RACStream *(id value) {
        @strongify(self);
        [Amplitude logEvent:@"Upload Image" withEventProperties:@{@"worldId": self.worldId}];
        UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
        return [fireService submitWorldMessage:self.worldId myUserId:userModel.userId mySpriteUrl:userModel.spriteUrl myName:userModel.name myUserImageUrl:userModel.imageUrl text:@"" imageUrl:value isObscuring:isObscuring location:self.lastKnownLocation];
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
    if (tableIsHidden) {
        self.mapView.hidden = NO;
        [Amplitude logEvent:@"Map Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
    }else{
        [Amplitude logEvent:@"Chat Table Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
    }
    self.tableView.hidden = !tableIsHidden;
    [self.textView becomeFirstResponder];
}

-(void)mapViewDidTap:(id)sender{
    [self.textView resignFirstResponder];
}

-(void)worldDetailDidClick:(id)sender{
    [Amplitude logEvent:@"World Detail Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
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
        [Amplitude logEvent:@"User Annotation Cell Did Click" withEventProperties:@{@"worldId": self.worldId, @"userId": userAnnotation.userId}];
        NSString *messageId = userAnnotation.messageId;
        @weakify(self);
        [self.messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            MessageModel *messageModel = obj;
            if ([messageId isEqualToString:messageModel.messageId]) {
                self.tableView.hidden = NO;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [self attemptToScrollToIndexPath:indexPath];
                *stop = YES;
            }
        }];
        
    }
}

-(void)centerMeButtonDidClick:(id)sender{
    [Amplitude logEvent:@"Center Me Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    UserAnnotation *userAnnotation = userAnnotations[myUserId];
    if (userAnnotation == nil) {
        return;
    }
    [self.mapView zoomToLocation:userAnnotation.coordinate withSpan:0.05];
    NSString *message = @"I centered the map on you!";
    [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    [proudSound play];
}

-(void)updateLocationButtonDidClick:(id)sender{
    [Amplitude logEvent:@"Update Location Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
    self.isAutoLocationUpdate = !self.isAutoLocationUpdate;
    if (self.isAutoLocationUpdate) {
        NSString *message = @"Location Auto Update is Now ON";
        [CSNotificationView showInViewController:self tintColor:[UIColor blueColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }else{
        NSString *message = @"Location Auto Update is Now OFF";
        [CSNotificationView showInViewController:self tintColor:[UIColor darkGrayColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:message duration:2.0];
    }
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

-(void)jiggleRandomUserAnnotation:(id)sender{
    @try {
        NSArray *array = [userAnnotations allKeys];
        if(array.count == 0){
            return;
        }
        int random = arc4random()%[array count];
        NSString *key = [array objectAtIndex:random];
        
        UserAnnotation *userAnno = [userAnnotations objectForKey:key];
        if (userAnno == nil) {
            return;
        }
        if (!userAnno.isObscuring) {
            return;
        }
        
        float randomLatFloat = [NCNumberHelper randomFloatBetweenMinRange:-0.001 maxRange:0.001];
        float randomLongFloat = [NCNumberHelper randomFloatBetweenMinRange:-0.001 maxRange:0.001];
        [UIView animateWithDuration:0.25 animations:^{
            userAnno.coordinate = CLLocationCoordinate2DMake(userAnno.coordinate.latitude + randomLatFloat, userAnno.coordinate.longitude + randomLongFloat);
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)clearNotificationBadgesForThisWorld:(id)sender{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [[[[[[[Firebase alloc] initWithUrl:kFirebaseRoot] childByAppendingPath:@"user-notification-badges"] childByAppendingPath:myUserId] childByAppendingPath:@"world-messages"] childByAppendingPath:self.worldId] setValue:@(0) withCompletionBlock:^(NSError *error, Firebase *ref) {
    }];
}

@end

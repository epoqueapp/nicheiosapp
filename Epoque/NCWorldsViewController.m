//
//  NCWorldsViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateNewWorldViewController.h"
#import "NCWorldChatViewController.h"
#import "NCWorldDetailViewController.h"
#import "NCNavigationController.h"
#import "NCWorldsViewController.h"
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCWorldService.h"
#import "WorldModel.h"
#import "NCWorldTableViewCell.h"
@interface NCWorldsViewController ()

@end

static NSString *WorldCellIdentifier = @"WorldCellIdentifier";

@implementation NCWorldsViewController{
    WorldModel *attemptWorld;
    NSMutableArray *worlds;
    NCFireService *fireService;
    NCUserService *userService;
    NCWorldService *worldService;
    UIBarButtonItem *createWorldBarButton;
    __block BOOL isInitialAdds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fireService = [NCFireService sharedInstance];
    userService  = [NCUserService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    worlds = [NSMutableArray array];
    [self setUpMenuButton];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCWorldTableViewCell" bundle:nil]forCellReuseIdentifier:WorldCellIdentifier];
    self.tableView.rowHeight = 162.0;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"WORLDS";
    createWorldBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(createNewWorld:)];
    self.navigationItem.rightBarButtonItems = @[createWorldBarButton];
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{
                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                 NSFontAttributeName: [UIFont fontWithName:kTrocchiBoldFontName size:16],
                                                                                                 }];
    @weakify(self);
    Firebase *worldsRef = [[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"];
    [worldsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [self addWorldModel:worldModel];
    }];
    [self animateClock:self];
    [worldsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [self fadeOutClock:self];
    }];
    
    [worldsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *changedWorldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [self changeWorldModel:changedWorldModel];
    }];
    
    [worldsRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *changedWorldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorldModel *currentWorld = [worlds objectAtIndex:idx];
            if ([changedWorldModel.worldId isEqualToString:currentWorld.worldId]) {
                [worlds removeObjectAtIndex:idx];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                *stop = YES;
            }
        }];
    }];
}

-(void)addWorldModel:(WorldModel *)worldModel{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if ([worldModel.favoritedUserIds containsObject:myUserId]) {
        [worlds insertObject:worldModel atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [worlds addObject:worldModel];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:worlds.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)changeWorldModel:(WorldModel *)changedWorldModel{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    
    [worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WorldModel *thisWorld = [worlds objectAtIndex:idx];
        if (![changedWorldModel.worldId isEqualToString:thisWorld.worldId]) {
            return;
        }
        //setup for modification;
        BOOL isOriginallyFavorited = [thisWorld.favoritedUserIds containsObject:myUserId];
        BOOL isNowFavorited = [changedWorldModel.favoritedUserIds containsObject:myUserId];
        
        if ((isOriginallyFavorited && isNowFavorited) || (!isNowFavorited && !isOriginallyFavorited)) {
            //just change it
            [worlds replaceObjectAtIndex:idx withObject:changedWorldModel];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (isOriginallyFavorited && !isNowFavorited) {
            //move this to bottom;
            [worlds removeObjectAtIndex:idx];
            [worlds addObject:changedWorldModel];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] toIndexPath:[NSIndexPath indexPathForRow:worlds.count -1 inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:worlds.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (!isOriginallyFavorited && isNowFavorited) {
            //move this to top
            [worlds removeObjectAtIndex:idx];
            [worlds insertObject:changedWorldModel atIndex:0];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)animateClock:(id)sender{
    self.minuteImageView.alpha = 1;
    self.hourImageView.alpha = 1;
    self.clockImageView.alpha = 1;
    [self.hourImageView runSpinAnimationWithDuration:2.0 isClockwise:YES];
    [self.minuteImageView runSpinAnimationWithDuration:3.0 isClockwise:NO];
}

-(void)fadeOutClock:(id)sender{
    @weakify(self);
    [UIView animateWithDuration:1.0 animations:^{
        @strongify(self);
        self.minuteImageView.alpha = 0;
        self.hourImageView.alpha = 0;
        self.clockImageView.alpha = 0;
    }];
}

-(void)createNewWorld:(id)sender{
    [Amplitude logEvent:@"Create New World Button Did Click"];
    NCCreateNewWorldViewController *createWorldViewController = [[NCCreateNewWorldViewController alloc]init];
    NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:createWorldViewController];
    createWorldViewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)attemptToEnterWorld:(WorldModel *)worldModel{
    NSDictionary *worldDictionary = [worldModel toDictionary];
    [Amplitude logEvent:@"World Did Click" withEventProperties:worldDictionary];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    BOOL containsMe = [worldModel.memberUserIds containsObject:myUserId];
    if (worldModel.isPrivate && !containsMe) {
        attemptWorld = worldModel;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"What's the secret?"
                                                          message:@"It's locked from the inside."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Continue", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView show];
        
        [[alertView textFieldAtIndex:0] setDelegate:self];
        [[alertView textFieldAtIndex:0] resignFirstResponder];
        [[alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypePhonePad];
        [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
        [[alertView textFieldAtIndex:0] becomeFirstResponder];
        return;
    }
    [self commitToEnterWorld:worldModel];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }
    if ([buttonTitle isEqualToString:@"Continue"] && inputText.length > 0 && [inputText isEqualToString:attemptWorld.passcode]) {
        [self commitToEnterWorld:attemptWorld];
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You entered the wrong pin..."
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
        [message show];
    }
}

-(void)commitToEnterWorld:(WorldModel *)worldModel{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSMutableArray *mutableMembers = [worldModel.memberUserIds mutableCopy];
    if (![mutableMembers containsObject:myUserId]) {
        [mutableMembers addObject:myUserId];
        [[[fireService.worldsRef childByAppendingPath:worldModel.worldId] childByAppendingPath:@"memberUserIds"] setValue:mutableMembers];
        [[[[fireService.rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:worldModel.worldId] childByAppendingPath:myUserId] setValue:@(YES)];
    }
    NCWorldChatViewController *worldChatViewController = [NCWorldChatViewController sharedInstance];
    worldChatViewController.worldId = [worldModel.worldId copy];
    [self.navigationController pushFadeViewController:worldChatViewController];
}

#pragma UICollectionView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return worlds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCWorldTableViewCell *cell = (NCWorldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:WorldCellIdentifier];
    
    WorldModel *worldModel = [worlds objectAtIndex:indexPath.row];
    [cell.worldImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
    cell.nameLabel.text = worldModel.name;
    cell.worldId = [worldModel.worldId copy];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if (worldModel.isPrivate && ![worldModel.memberUserIds containsObject:myUserId]) {
        cell.keyImageView.hidden = NO;
    }else{
        cell.keyImageView.hidden = YES;
    }
    cell.starImageView.hidden = ![worldModel.favoritedUserIds containsObject:myUserId];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WorldModel *worldModel = [worlds objectAtIndex:indexPath.row];
    [self attemptToEnterWorld:worldModel];
}

@end

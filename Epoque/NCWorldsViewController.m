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
#import "NCWorldTableViewCell.h"
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCWorldService.h"
#import "WorldModel.h"
#import "NCWorldCollectionViewCell.h"
@interface NCWorldsViewController ()

@end

static NSString *WorldCellIdentifier = @"WorldCellIdentifier";

@implementation NCWorldsViewController{
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"NCWorldCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:WorldCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    
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
        [worlds addObject:worldModel];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:worlds.count -1 inSection:0]]];
    }];
    [self animateClock:self];
    [worldsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        [self fadeOutClock:self];
    }];
    
    [worldsRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *changedWorldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorldModel *currentWorld = [worlds objectAtIndex:idx];
            if ([changedWorldModel.worldId isEqualToString:currentWorld.worldId]) {
                [worlds replaceObjectAtIndex:idx withObject:changedWorldModel];
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                *stop = YES;
            }
        }];
    }];
    
    [worldsRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *changedWorldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorldModel *currentWorld = [worlds objectAtIndex:idx];
            if ([changedWorldModel.worldId isEqualToString:currentWorld.worldId]) {
                [worlds removeObjectAtIndex:idx];
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                *stop = YES;
            }
        }];
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return worlds.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NCWorldCollectionViewCell *cell = (NCWorldCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:WorldCellIdentifier forIndexPath:indexPath];
    
    WorldModel *worldModel = [worlds objectAtIndex:indexPath.row];
    [cell.worldImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
    cell.worldNameLabel.text = worldModel.name;
    cell.keyImageView.hidden = ![self isLocked:worldModel];
    cell.starImageView.hidden = ![self isFavorite:worldModel];
    cell.alpha = 0;
    cell.transform = CGAffineTransformScale(cell.transform, 0.25, 0.25);
    [UIView animateWithDuration:0.25 animations:^{
        cell.alpha = 1;
        cell.transform = CGAffineTransformIdentity;
    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WorldModel *worldModel = [worlds objectAtIndex:indexPath.row];
    [self attemptToEnterWorld:worldModel];
}

#pragma Cell Logic

-(BOOL)isLocked:(WorldModel *)worldModel{
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if (worldModel.isPrivate) {
        return ![worldModel.memberUserIds containsObject:userId];
    }
    return NO;
}

-(BOOL)isFavorite:(WorldModel *)worldModel {
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    return [worldModel.favoritedUserIds containsObject:userId];
}

@end

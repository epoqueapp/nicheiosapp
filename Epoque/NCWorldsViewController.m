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
    [self.tableView registerNib:[UINib nibWithNibName:@"NCWorldTableViewCell" bundle:nil] forCellReuseIdentifier:WorldCellIdentifier];
    [self.tableView setRowHeight:90.0];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"WORLDS";
    
    createWorldBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(createNewWorld:)];
    
    self.navigationItem.rightBarButtonItems = @[createWorldBarButton];
    
    
    @weakify(self);
    isInitialAdds = YES;
    FQuery *query = [fireService.worldsRef queryOrderedByChild:@"isDefault"];
    
    [query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [worlds insertObject:worldModel atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    [query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        for (int i = 0 ; i < worlds.count; i ++) {
            WorldModel *foundWorld = [worlds objectAtIndex:i];
            if ([foundWorld.worldId isEqualToString:worldModel.worldId]) {
                [worlds removeObjectAtIndex:i];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
    
    [query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        for (int i = 0 ; i < worlds.count; i ++) {
            WorldModel *foundWorld = [worlds objectAtIndex:i];
            if ([foundWorld.worldId isEqualToString:worldModel.worldId]) {
                [worlds replaceObjectAtIndex:i withObject:worldModel];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WorldModel *selectedWorldModel = [worlds objectAtIndex:indexPath.row];
    NSDictionary *worldDictionary = [selectedWorldModel toDictionary];
    [Amplitude logEvent:@"World Did Click" withEventProperties:worldDictionary];
    @try {
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        NSMutableArray *mutableMembers = [selectedWorldModel.memberUserIds mutableCopy];
        if (![mutableMembers containsObject:myUserId]) {
            [mutableMembers addObject:myUserId];
            [[[fireService.worldsRef childByAppendingPath:selectedWorldModel.worldId] childByAppendingPath:@"memberUserIds"] setValue:mutableMembers];
            [[[[fireService.rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:selectedWorldModel.worldId] childByAppendingPath:myUserId] setValue:@(YES)];
        }
        NCWorldChatViewController *worldChatViewController = [NCWorldChatViewController sharedInstance];
        worldChatViewController.worldId = [selectedWorldModel.worldId copy];
        [self.navigationController pushRetroViewController:worldChatViewController];
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    } @finally {
        //NSLog(@"finally");
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return worlds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCWorldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WorldCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    WorldModel *world = [worlds objectAtIndex:indexPath.row];
    cell.nameLabel.text = world.name;
    cell.detailLabel.text = world.detail;
    cell.detailLabel.textColor = [UIColor whiteColor];
    cell.detailLabel.font = [UIFont fontWithName:kTrocchiFontName size:12.0];
    NSString *imageUrl = world.imageUrl;
    [cell.emblemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (cacheType == SDImageCacheTypeNone) {
            cell.emblemImageView.alpha = 0;
            [UIView animateWithDuration:0.1 animations:^{
                cell.emblemImageView.alpha = 1;
            }];
        }else{
            cell.emblemImageView.alpha = 1;
        }
    }];
    cell.alpha = 0;
    cell.memberCountLabel.text = [NSString stringWithFormat:@"%lu", world.memberUserIds.count];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    BOOL isAFavoriteWorld = [world.favoritedUserIds containsObject: myUserId];
    if(isAFavoriteWorld){
        cell.privateImageView.hidden = NO;
        cell.privateImageView.image = [UIImage imageNamed:@"star_icon"];
    }
    else{
        cell.privateImageView.hidden = YES;
    }
    return cell;
}

-(void)createNewWorld:(id)sender{
    [Amplitude logEvent:@"Create New World Button Did Click"];
    NCCreateNewWorldViewController *createWorldViewController = [[NCCreateNewWorldViewController alloc]init];
    NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:createWorldViewController];
    createWorldViewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end

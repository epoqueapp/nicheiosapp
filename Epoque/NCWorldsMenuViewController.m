//
//  NCWorldsMenuViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldsMenuViewController.h"
#import "NCWorldsMenuViewController+EntryEvents.h"
#import "NCEditWorldViewController.h"
#import "NCNavigationController.h"
@interface NCWorldsMenuViewController ()

@end

@implementation NCWorldsMenuViewController

static NSString * const  kWorldTableViewCellIdentifier = @"kWorldTableViewCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.worlds = [NSMutableArray array];
    self.view.backgroundColor = [UIColor blackColor];
    self.customNavbar.tintColor = [UIColor whiteColor];
    self.customNavbar.barTintColor =[UIColor blackColor];
    self.customNavbar.translucent = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#141414"];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"NCWorldTableViewCell" bundle:nil] forCellReuseIdentifier:kWorldTableViewCellIdentifier];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
    FQuery *worldsQuery = [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"] queryOrderedByChild:@"isDefault"];
    @weakify(self);
    [worldsQuery observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [self.worlds addObject:worldModel];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.worlds.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    [worldsQuery observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [self.worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorldModel *thisWorldModel = obj;
            if ([worldModel.worldId isEqualToString:thisWorldModel.worldId]) {
                [self.worlds removeObject:obj];
                [self.worlds insertObject:worldModel atIndex:idx];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }];
    
    [worldsQuery observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        [self.worlds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorldModel *thisWorldModel = obj;
            if ([worldModel.worldId isEqualToString:thisWorldModel.worldId]) {
                [self.worlds removeObject:obj];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    
    UIBarButtonItem *addWorldBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"plus_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(addWorldButtonDidClick:)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"WORLDS"];
    item.rightBarButtonItem = addWorldBarButtonItem;
    item.hidesBackButton = YES;
    
    [self.customNavbar pushNavigationItem:item animated:NO];
    
    [[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCUserModel] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addWorldButtonDidClick:(id)sender{
    NCEditWorldViewController *editWorldViewController = [[NCEditWorldViewController alloc]init];
    NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:editWorldViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.worlds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCWorldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWorldTableViewCellIdentifier];
    WorldModel *worldModel = (WorldModel *)[self.worlds objectAtIndex:indexPath.row];
    [cell setWorldModel:worldModel];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WorldModel *worldModel = [self.worlds objectAtIndex:indexPath.row];
    
    NSString *currentWorldId = [NSUserDefaults standardUserDefaults].currentWorldId;
    if ([currentWorldId isEqualToString:worldModel.worldId]) {
        [self.sideMenuViewController hideMenuViewController];
        return;
    }
    
    [self attemptEntryToWorld:worldModel];
}

@end

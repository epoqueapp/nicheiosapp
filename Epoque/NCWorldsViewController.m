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
#import "NCWorldService.h"
#import "NCUserService.h"
#import "WorldModel.h"
@interface NCWorldsViewController ()

@end

static NSString *WorldCellIdentifier = @"WorldCellIdentifier";

@implementation NCWorldsViewController{
    NSMutableArray *worlds;
    NCFireService *fireService;
    NCWorldService *worldService;
    NCUserService *userService;
    Mixpanel *mixpanel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mixpanel = [Mixpanel sharedInstance];
    worldService = [NCWorldService sharedInstance];
    fireService = [NCFireService sharedInstance];
    userService  = [NCUserService sharedInstance];
    worlds = [NSMutableArray array];
    [self setUpMenuButton];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCWorldTableViewCell" bundle:nil] forCellReuseIdentifier:WorldCellIdentifier];
    [self.tableView setRowHeight:80.0];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.searchBar.barTintColor = [UIColor clearColor];
    self.searchBar.delegate = self;
    self.title = @"WORLDS";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(createNewWorld:)];
    
    UITextField *textField = [self.searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
     [self fetchMyWorlds:nil];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
   
}

-(void)refresh:(id)sender{
    if (self.searchBar.text.length > 0) {
        [self searchWorlds:sender];
    }else{
        [self fetchMyWorlds:sender];
    }
}

-(void)fetchMyWorlds:(id)sender{
    @weakify(self);
    [mixpanel timeEvent:@"Get My Worlds"];
    [[[[[[RACSignal return:@(1)] delay:0.25] doNext:^(id x) {
        @strongify(self);
        [NCLoadingView showInView:self.view withTitleText:@"Loading..."];
    }] flattenMap:^RACStream *(id value) {
        return [worldService getMyWorlds];
    }] retry:3] subscribeNext:^(NSArray *myWorlds) {
        [mixpanel track:@"Get My Worlds"];
        @strongify(self);
        self.title = @"MY WORLDS";
        worlds = [NSMutableArray arrayWithArray:myWorlds];
        [self.tableView reloadData];
        [NCLoadingView hideAllFromView:self.view];
    } error:^(NSError *error) {
        [NCLoadingView hideAllFromView:self.view];
    }];
}

-(void)searchWorlds:(id)sender{
    @weakify(self);
    [NCLoadingView showInView:self.view withTitleText:@"Searching..."];
    [mixpanel timeEvent:@"Search Worlds"];
    [[worldService searchWorlds:self.searchBar.text] subscribeNext:^(id x) {
        @strongify(self);
        [mixpanel track:@"Search World" properties:@{@"Search Term": self.searchBar.text}];
        self.title = @"FOUND WORLDS";
        NSArray *fetchedWorlds = [WorldModel arrayOfModelsFromDictionaries:[x objectForKey:@"worlds"]];
        worlds = [NSMutableArray arrayWithArray:fetchedWorlds];
        [self.tableView reloadData];
        [NCLoadingView hideAllFromView:self.view];
    } error:^(NSError *error) {
        [NCLoadingView hideAllFromView:self.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchWorlds:searchBar];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [mixpanel track:@"Canceled Searching Worlds"];
    [searchBar resignFirstResponder];
    [self fetchMyWorlds:nil];
    searchBar.text = @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WorldModel *selectedWorldModel = [worlds objectAtIndex:indexPath.row];
    
    @try {
        NCWorldChatViewController *worldChatViewController = [NCWorldChatViewController sharedInstance];
        worldChatViewController.worldId = [selectedWorldModel.worldId copy];
        [self.navigationController pushRetroViewController:worldChatViewController];
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    } @finally {
        //NSLog(@"finally");
    }
    
    
    NSDictionary *worldDictionary = [selectedWorldModel toDictionary];
    [mixpanel track:@"World Did Click" properties:worldDictionary];
    [[[worldService joinWorldById:selectedWorldModel.worldId] retry:30] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        
    }];
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
    cell.emblemImageView.alpha = 0;
    [cell.emblemImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.emblemImageView.alpha = 1;
        }];
    }];
    cell.alpha = 0;
    CGRect originalFrame = cell.frame;
    CGRect startFrame = CGRectMake(originalFrame.origin.x + 30, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    cell.frame = startFrame;
    [UIView animateWithDuration:0.25 animations:^{
        cell.alpha = 1;
        cell.frame = originalFrame;
    }];
    
    if (world.isPrivate) {
        cell.privateImageView.hidden = NO;
    }else{
        cell.privateImageView.hidden = YES;
    }
    
    if (world.isDefault) {
        cell.privateImageView.hidden = NO;
        cell.privateImageView.image = [UIImage imageNamed:@"saturn_icon"];
    }else{
        cell.privateImageView.hidden = YES;
    }
    
    return cell;
}

-(void)createNewWorld:(id)sender{
    [mixpanel track:@"Create New World Button Did Click"];
    NCCreateNewWorldViewController *createWorldViewController = [[NCCreateNewWorldViewController alloc]init];
    NCNavigationController *navigationController = [[NCNavigationController alloc]initWithRootViewController:createWorldViewController];
    createWorldViewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)shouldRefresh:(id)sender{
    [self fetchMyWorlds:nil];
}

@end

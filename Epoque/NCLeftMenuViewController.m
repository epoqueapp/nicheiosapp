//
//  NCLeftMenuViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLeftMenuViewController.h"
#import "NCWelcomeViewController.h"
#import "NCFeedbackViewController.h"
#import "NCMapViewController.h"
#import "NCMyCharacterViewController.h"
#import "NCNavigationController.h"
#import "NCLeftMenuTableViewCell.h"
#import "NCFireService.h"
#import "NCAboutViewController.h"
#import "NCMapViewController.h"
@interface NCLeftMenuViewController ()

@end
NSString* MenuCellIdentifier = @"MenuCellIdentifier";
@implementation NCLeftMenuViewController{
    NSMutableArray *mutableArray;
    NCFireService *fireService;
    CGRect flareOriginalFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    flareOriginalFrame = self.flareImageView.frame;
    
    mutableArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 50.0;
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCLeftMenuTableViewCell" bundle:nil] forCellReuseIdentifier:MenuCellIdentifier];
    fireService = [NCFireService sharedInstance];
    self.sideMenuViewController.delegate = self;
    
    
    RACSignal *willShowMenuView = [self rac_signalForSelector:@selector(sideMenu:willShowMenuViewController:) fromProtocol:@protocol(RESideMenuDelegate)];
    RACSignal *returnedFromBackground = [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil];
    RACSignal *shouldSpin = [[RACSignal merge:@[willShowMenuView, returnedFromBackground]] map:^id(id value) {
        return [RACSignal empty];
    }];
    [self rac_liftSelector:@selector(spinHands:) withSignals:shouldSpin, nil];
    
}

-(void)spinHands:(id)sender{
    [self.hourHandImageView runSpinAnimationWithDuration:3.0 isClockwise:YES];
    [self.minuteHandImageView runSpinAnimationWithDuration:4.0 isClockwise:NO];
}

-(void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController{
    mutableArray = [NSMutableArray array];
    [self.tableView reloadData];
}

-(void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController{
    mutableArray = [NSMutableArray arrayWithObjects:@"WORLD MAP",  @"MY CHARACTER", @"ABOUT", @"FEEDBACK", nil];
    [self.tableView reloadData];
}

-(void)sideMenu:(RESideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer{
    float xVal = [recognizer locationInView:self.view].x;
    self.flareImageView.frame = CGRectMake(flareOriginalFrame.origin.x  + (-0.25 *xVal), flareOriginalFrame.origin.y, flareOriginalFrame.size.width, flareOriginalFrame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mutableArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCLeftMenuTableViewCell *cell = (NCLeftMenuTableViewCell* )[tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier];
    if (cell == nil) {
        cell = [[NCLeftMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifier];
    }
    
    NSString *titleText = [mutableArray objectAtIndex:indexPath.row];
    cell.menuItemLabel.text = titleText;
    cell.alpha = 0;
    CGRect originalFrame = cell.frame;
    CGRect startFrame = CGRectMake(originalFrame.origin.x + 50, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    cell.frame = startFrame;
    [UIView animateWithDuration:0.25 delay:(indexPath.row * 0.05) options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.alpha = 1;
        cell.frame = originalFrame;
    } completion:nil];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *menuTitle = [mutableArray objectAtIndex:indexPath.row];
    if ([menuTitle isEqualToString:@"WORLD MAP"]) {
        [Amplitude logEvent:@"World Map Menu Item Did Click"];
        NSString *worldId = [[[NSUserDefaults standardUserDefaults] currentWorldId] copy];
        NCMapViewController *mapViewController = [[NCMapViewController alloc]initWithWorldId:worldId];
        NCNavigationController *navController = [[NCNavigationController alloc]initWithRootViewController:mapViewController];
        [self.sideMenuViewController customSetContentViewController:navController];
        [self.sideMenuViewController hideMenuViewController];
    }
    if ([menuTitle isEqualToString:@"MY CHARACTER"]) {
        [Amplitude logEvent:@"My Character Menu Item Did Click"];
        NCMyCharacterViewController *myCharacterViewController = [[NCMyCharacterViewController alloc]init];
        NCNavigationController *navController = [[NCNavigationController alloc]initWithRootViewController:myCharacterViewController];
        [self.sideMenuViewController customSetContentViewController:navController];
        [self.sideMenuViewController hideMenuViewController];
    }
    if ([menuTitle isEqualToString:@"ABOUT"]) {
        [Amplitude logEvent:@"About Menu Item Did Click"];
        NCAboutViewController *aboutViewController = [[NCAboutViewController alloc]init];
        NCNavigationController *navController = [[NCNavigationController alloc]initWithRootViewController:aboutViewController];
        [self.sideMenuViewController customSetContentViewController:navController];
        [self.sideMenuViewController hideMenuViewController];
    }
    if ([menuTitle isEqualToString:@"FEEDBACK"]) {
        [Amplitude logEvent:@"Feedback Menu Item Did Click"];
        NCFeedbackViewController *feedbackViewController = [[NCFeedbackViewController alloc]init];
        NCNavigationController *navController = [[NCNavigationController alloc]initWithRootViewController:feedbackViewController];
        [self.sideMenuViewController customSetContentViewController:navController];
        [self.sideMenuViewController hideMenuViewController];
    }
}


@end

//
//  AppDelegate.m
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCWelcomeViewController.h"
#import "NCNavigationController.h"
#import "NCLeftMenuViewController.h"
#import "NCMapViewController.h"
#import "NCWorldsMenuViewController.h"
#import <RESideMenu/RESideMenu.h>
@interface AppDelegate ()

@end

@implementation AppDelegate{
    NCFireService *fireService;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HockeyAppIdentifier"]];
    // Configure the SDK in here only!
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    [Amplitude initializeApiKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AmplitudeApiKey"]];
    fireService = [NCFireService sharedInstance];
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    self.mapView = [[MKMapView alloc]init];
    [self submitDeviceToken];
    [self observeUserChange];
    [self observeQuoteChange];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    NCNavigationController  *navigationController = [self navigationControllerFromPush:userInfo];
    NCLeftMenuViewController *leftMenuViewController = [[NCLeftMenuViewController alloc] init];
    NCNavigationController *rightMenuViewController = [[NCNavigationController alloc]initWithRootViewController: [[NCWorldsMenuViewController alloc]init]];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc]initWithContentViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:rightMenuViewController];
    sideMenuViewController.panFromEdge = NO;
    sideMenuViewController.panGestureEnabled = NO;
    self.window.rootViewController = sideMenuViewController;
    [self.window makeKeyAndVisible];
    application.applicationIconBadgeNumber = 0;
    
    NSLog(@"Running Build Configuration: %@", [AppDelegate buildConfiguration]);
    return YES;
}

-(void)submitDeviceToken{
    RACSignal *userModel = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCUserModel];
    RACSignal *deviceToken = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCDeviceToken];
    NSString *buildConfiguration = [AppDelegate buildConfiguration];
    
    [[[[[[RACSignal combineLatest:@[userModel, deviceToken] reduce:^id(NSDictionary *userDictionary, NSString *deviceToken){
        NSString *userId = userDictionary[@"userId"];
        return RACTuplePack(userId, deviceToken);
    }] filter:^BOOL(RACTuple *tuple) {
        NSString *userId = tuple.first;
        NSString *deviceToken = tuple.second;
        return userId != nil && deviceToken != nil;
    }] doNext:^(RACTuple *tuple) {
        
    }] flattenMap:^RACStream *(RACTuple *tuple) {
        return [[NCFireService sharedInstance] registerUserId:tuple.first deviceToken:tuple.second environment:buildConfiguration];
    }] retry:500] subscribeNext:^(id x) {
        NSLog(@"Successfully registered the device token to the remote service");
    } error:^(NSError *error) {
        NSLog(@"There was an error registering the device token with the service: %@", [error localizedDescription]);
    }];;
}

-(void)observeUserChange{
    [fireService.usersRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSString *changedUserId = snapshot.key;
        UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
        if (userModel == nil) {
            return;
        }
        if ([changedUserId isEqualToString:userModel.userId]) {
            UserModel *newUserModel = [[UserModel alloc]initWithSnapshot:snapshot];
            [[NSUserDefaults standardUserDefaults] setUserModel:newUserModel];
            [Amplitude setUserId:newUserModel.userId];
            [Amplitude setUserProperties:[newUserModel toDictionary]];
        }
    }];
    
    [[[Firebase alloc]initWithUrl:kFirebaseRoot] observeAuthEventWithBlock:^(FAuthData *authData) {
        if (authData) {
            
        }else{
            [[NSUserDefaults standardUserDefaults] clearAuthInformation];
        }
    }];
}

-(void)observeQuoteChange{
    [[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"quotes"] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            return;
        }
        NSMutableArray *quoteObjects = [NSMutableArray array];
        for (id key in snapshot.value) {
            [quoteObjects addObject:[snapshot.value objectForKey:key]];
        }
        [[NSUserDefaults standardUserDefaults] setQuotes:quoteObjects];
    }];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * tokenAsString = [[[deviceToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setDeviceToken:tokenAsString];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed To Register Remote Notification With Error:%@",error);
    [Amplitude logEvent:@"Failed To Register For Remote Notification" withEventProperties:@{@"localizedError": error.localizedDescription}];
}

-(NCNavigationController *)navigationControllerFromPush:(NSDictionary *)userInfo{
    FAuthData *authData = [[Firebase alloc]initWithUrl:kFirebaseRoot].authData;
    if (authData != nil) {
        NSString *worldId = [NSUserDefaults standardUserDefaults].currentWorldId;
        if ([[userInfo objectForKey:@"pushType"] isEqualToString:@"worldMessage"]) {
            worldId = [userInfo objectForKey:@"worldId"];
            [[NSUserDefaults standardUserDefaults] setCurrentWorldId:worldId];
        }
        NCMapViewController *mapViewController = [[NCMapViewController alloc]initWithWorldId:worldId];
        return [[NCNavigationController alloc]initWithRootViewController:mapViewController];
    }
    return [[NCNavigationController alloc]initWithRootViewController:[[NCWelcomeViewController alloc] init]];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    application.applicationIconBadgeNumber = 0;
    if ( application.applicationState == UIApplicationStateActive ){
        return;
    }
    FAuthData *authData = [[Firebase alloc]initWithUrl:kFirebaseRoot].authData;
    if (authData != nil) {
        NCNavigationController *navController = [self navigationControllerFromPush:userInfo];
        [((RESideMenu *)self.window.rootViewController) customSetContentViewController:navController];
    }
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

+(NSString *)buildConfiguration{
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"BuildConfiguration"] lowercaseString];
}

@end

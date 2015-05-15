//
//  AppDelegate.m
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "AppDelegate.h"
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCWorldsViewController.h"
#import "NCWelcomeViewController.h"
#import "NCNavigationController.h"
#import "NCLeftMenuViewController.h"
#import "NCWorldChatViewController.h"
#import <RESideMenu/RESideMenu.h>
#import <AWSCore/AWSCore.h>
@interface AppDelegate ()

@end

@implementation AppDelegate{
    NCFireService *fireService;
    NCSoundEffect *privateMessageSoundEffect;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Crittercism enableWithAppID: @"552cb5038172e25e679068ce"];
    [Amplitude initializeApiKey:@"fc2d3b020cdd10d12d3ee14c1d7c7a59"];
    fireService = [NCFireService sharedInstance];
    privateMessageSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"table_shout.wav"];
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    self.mapView = [[MKMapView alloc]init];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [self submitDeviceToken];
    [self observeUserChange];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    NCNavigationController  *navigationController = [self navigationControllerFromPush:userInfo];
    NCLeftMenuViewController *leftMenuViewController = [[NCLeftMenuViewController alloc] init];
    RESideMenu *sideMenuViewController = [[RESideMenu alloc]initWithContentViewController:navigationController leftMenuViewController:leftMenuViewController rightMenuViewController:nil];
    self.window.rootViewController = sideMenuViewController;
    [self.window makeKeyAndVisible];
    application.applicationIconBadgeNumber = 0;
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

-(void)submitDeviceToken{
    RACSignal *userModel = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCUserModel];
    RACSignal *deviceToken = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCDeviceToken];
    
    [[[[[RACSignal combineLatest:@[userModel, deviceToken] reduce:^id(NSDictionary *userDictionary, NSString *deviceToken){
        NSString *userId = userDictionary[@"userId"];
        return RACTuplePack(userId, deviceToken);
    }] filter:^BOOL(RACTuple *tuple) {
        NSString *userId = tuple.first;
        NSString *deviceToken = tuple.second;
        return userId != nil && deviceToken != nil;
    }] flattenMap:^RACStream *(RACTuple *tuple) {
        return [[NCFireService sharedInstance] registerUserId:tuple.first deviceToken:tuple.second environment:kNCAPSEnvironment];
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
        }
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
    if ([NSUserDefaults standardUserDefaults].userModel == nil) {
        return [[NCNavigationController alloc]initWithRootViewController:[[NCWelcomeViewController alloc] init]];
    }
    NSString *pushType = userInfo[@"pushType"];
    if ([pushType isEqualToString:@"world"]) {
        NSString *worldId = userInfo[@"worldId"];
        [Amplitude logEvent:@"Reacted To Push Notification" withEventProperties:@{@"pushType":pushType, @"worldId": worldId}];
        NCWorldChatViewController *worldChatViewController = [NCWorldChatViewController sharedInstance];
        worldChatViewController.worldId = worldId;
        NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
        NCNavigationController *navigationController = [[NCNavigationController alloc]init];
        [navigationController setViewControllers:@[worldsViewController, worldChatViewController]];
        return navigationController;
    }else{
        NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
        NCNavigationController *navigationController = [[NCNavigationController alloc]init];
        [navigationController setViewControllers:@[worldsViewController]];
        return navigationController;
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if ( application.applicationState == UIApplicationStateActive ){
    }else{
        //app was brought from the background to the foreground
        NSString *pushType = userInfo[@"pushType"];
        if ([pushType isEqualToString:@"world"]) {
            NSString *worldId = userInfo[@"worldId"];
            [Amplitude logEvent:@"Reacted To Push Notification" withEventProperties:@{@"pushType":pushType, @"worldId": worldId}];
            NCWorldChatViewController *worldChatViewController = [NCWorldChatViewController sharedInstance];
            worldChatViewController.worldId = worldId;
            NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
            NCNavigationController *navigationController = [[NCNavigationController alloc]init];
            [navigationController setViewControllers:@[worldsViewController, worldChatViewController]];
            [((RESideMenu *)self.window.rootViewController) setContentViewController:navigationController];
        }
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
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end

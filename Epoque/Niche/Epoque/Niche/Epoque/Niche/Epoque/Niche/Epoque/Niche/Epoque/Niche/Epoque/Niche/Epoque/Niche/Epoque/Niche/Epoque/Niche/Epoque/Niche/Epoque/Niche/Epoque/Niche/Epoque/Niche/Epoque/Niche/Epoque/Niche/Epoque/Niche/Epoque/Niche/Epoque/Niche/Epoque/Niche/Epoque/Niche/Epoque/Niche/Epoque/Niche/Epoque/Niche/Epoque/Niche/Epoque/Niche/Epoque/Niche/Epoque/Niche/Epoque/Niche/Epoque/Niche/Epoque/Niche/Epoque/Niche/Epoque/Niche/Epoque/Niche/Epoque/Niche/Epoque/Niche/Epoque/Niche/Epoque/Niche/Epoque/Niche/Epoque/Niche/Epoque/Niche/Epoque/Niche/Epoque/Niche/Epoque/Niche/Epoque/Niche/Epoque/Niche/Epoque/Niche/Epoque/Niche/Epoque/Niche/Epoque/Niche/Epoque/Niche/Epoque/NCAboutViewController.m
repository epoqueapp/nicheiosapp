//
//  NCAboutViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCAboutViewController.h"

@interface NCAboutViewController ()

@end

@implementation NCAboutViewController{
    Mixpanel *mixpanel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpMenuButton];
    self.title = @"ABOUT";
    mixpanel = [Mixpanel sharedInstance];
    
    self.privacyPolicyButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [mixpanel track:@"Privacy Policy Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/privacy-policy"]];
        return [RACSignal empty];
    }];
    
    self.visitWebsiteButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [mixpanel track:@"Website Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/"]];
        return [RACSignal empty];
    }];
    
    self.termsOfServiceButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
         [mixpanel track:@"Terms of Service Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/terms-of-service"]];
        return [RACSignal empty];
    }];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    self.versionAndBuildLabel.text = [NSString stringWithFormat:@"Version: %@ Build :%@", version, build];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

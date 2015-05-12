//
//  NCWelcomeViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWelcomeViewController.h"
#import "NCSpritesViewController.h"
@interface NCWelcomeViewController ()

@end

@implementation NCWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    self.beginButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
        [self.navigationController pushViewController:spritesViewController animated:YES];
        return [RACSignal empty];
    }];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:nil] takeUntil:[self rac_signalForSelector:@selector(viewWillDisappear:)]] subscribeNext:^(id x) {
        @strongify(self);
        NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
        [self.navigationController pushFadeViewController:spritesViewController];
    }];
    self.view.backgroundColor = [UIColor blackColor];
    NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:stringPath];
    self.moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
    self.moviePlayer.view.frame = self.view.frame;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    [self.view addSubview:self.moviePlayer.view];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.moviePlayer.view.center = self.view.center;
    self.moviePlayer.view.transform = CGAffineTransformMakeScale(1, 1);
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.moviePlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  NCWelcomeViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface NCWelcomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *beginButton;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end

//
//  NCAboutViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCAboutViewController.h"
#import "NCSoundEffect.h"
@interface NCAboutViewController ()

@end

@implementation NCAboutViewController{
    NCSoundEffect *soundEffect;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpMenuButton];
    self.title = @"ABOUT";
    soundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"guitar_jingle.mp3"];
    
    self.privacyPolicyButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [Amplitude logEvent:@"Privacy Policy Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/privacy-policy"]];
        return [RACSignal empty];
    }];
    
    self.visitWebsiteButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [Amplitude logEvent:@"Website Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/"]];
        return [RACSignal empty];
    }];
    
    self.termsOfServiceButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
         [Amplitude logEvent:@"Terms of Service Button Did Click"];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://epoqueapp.com/terms-of-service"]];
        return [RACSignal empty];
    }];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    self.versionAndBuildLabel.text = [NSString stringWithFormat:@"Version: %@ Build :%@", version, build];
    self.backgroundImageView.alpha = 0;
    [self addShadows];
    
    self.quotesLabel.textColor = [UIColor whiteColor];
    self.quotesLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:16.0];
    self.quotesLabel.strokeColor = [UIColor blackColor];
    self.quotesLabel.strokeSize = 1.5;
    self.quotesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *randomQuote = [NSUserDefaults standardUserDefaults].randomQuote;
    NSString *content = [randomQuote objectForKey:@"content"];
    NSString *author = [randomQuote objectForKey:@"author"];
    self.quotesLabel.text = [NSString stringWithFormat:@"%@ ~ %@", content, author];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(changeQuote:) userInfo:nil repeats:YES];
}

-(void)changeQuote:(id)sender{
    self.quotesLabel.alpha = 1;
    @weakify(self);
    [UIView animateWithDuration:2.0 animations:^{
        @strongify(self);
        self.quotesLabel.alpha = 0;
    }completion:^(BOOL finished) {
        @strongify(self);
        
        if (finished) {
            NSDictionary *randomQuote = [NSUserDefaults standardUserDefaults].randomQuote;
            NSString *content = [randomQuote objectForKey:@"content"];
            NSString *author = [randomQuote objectForKey:@"author"];
            self.quotesLabel.text = [NSString stringWithFormat:@"%@ \n ~ %@", content, author];
        }
        
    }];
    
    [UIView animateWithDuration:2.0 delay:2.0 options:0 animations:^{
        @strongify(self);
        self.quotesLabel.alpha = 1;
    } completion:^(BOOL finished){
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:2.0 animations:^{
        self.backgroundImageView.alpha = 1;
    }];
    [soundEffect play];
    NSLog(@"%@", [NSString generateRandomPIN:4]);
}

-(void)addShadows{
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.shadowColor = [UIColor blackColor];
            button.titleLabel.shadowOffset = CGSizeMake(1.25, 1.25);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  NCBlurbDetailViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/8/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCBlurbDetailViewController.h"
#import "BlurbModel.h"
#import "NCBlurbService.h"
@interface NCBlurbDetailViewController ()

@end

@implementation NCBlurbDetailViewController{
    NCBlurbService *blurbService;
}

-(id)initWithWorldId:(NSString *)worldId blurbId:(NSString *)blurbId{
    self = [super init];
    if (self) {
        self.worldId = worldId;
        self.blurbId = blurbId;
        blurbService = [NCBlurbService sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDismissButtonWithTarget:self selector:@selector(dismissMe:)];
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 190, 20,20)];
    [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadingIndicator setHidesWhenStopped:YES];
    [self.webView addSubview:loadingIndicator];
    
    [loadingIndicator startAnimating];
    
    RACSignal *blurbSignal = [blurbService observeSingleBlurbByWorldId:self.worldId blurbId:self.blurbId];
    RACSignal *loadWebsite = [blurbSignal map:^id(BlurbModel *blurbModel) {
        NSURL *websiteUrl = [NSURL URLWithString:blurbModel.websiteUrl];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:websiteUrl];
        return request;
    }];
    
    RACSignal *websiteTitle = [blurbSignal map:^id(BlurbModel *blurbModel) {
        return blurbModel.name;
    }];
    
    
    [self rac_liftSelector:@selector(setTitle:) withSignals:websiteTitle, nil];
    [self.webView rac_liftSelector:@selector(loadRequest:) withSignals:loadWebsite, nil];
    [[self rac_signalForSelector:@selector(webViewDidFinishLoad:) fromProtocol:@protocol(UIWebViewDelegate)] subscribeNext:^(id x) {
        [loadingIndicator stopAnimating];
    }];
}

-(void)dismissMe:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

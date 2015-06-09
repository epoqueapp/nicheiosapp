//
//  NCBlurbDetailViewController.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/8/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCBlurbDetailViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, copy) NSString *blurbId;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIButton *directionsButton;

-(id)initWithWorldId:(NSString *)worldId blurbId:(NSString *)blurbId;

@end

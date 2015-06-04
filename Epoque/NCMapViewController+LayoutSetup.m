//
//  NCMapViewController+LayoutSetup.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController+LayoutSetup.h"
#import "NCMapViewController+ButtonEvents.h"
@implementation NCMapViewController (LayoutSetup)

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

-(void)setUpTextView:(id)sender{
    self.textView.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.textView.font = [UIFont fontWithName:kTrocchiFontName size:16.0];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor darkGrayColor];
    self.textView.placeholder = @"Don't be shy...";
    self.textView.placeholderColor = [UIColor grayColor];
    self.textInputbar.backgroundColor = [UIColor blackColor];
    self.rightButton.titleLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:16.0];
    self.rightButton.titleLabel.textColor = [UIColor colorWithHexString:@"#5EA4FF"];
}

-(void)setUpMapView:(id)sender{
    self.mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view insertSubview:self.mapView belowSubview:self.tableView];
}

-(void)setUpTableView:(id)sender{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#141414"];
    [self.tableView registerClass:[NCMessageTableViewCell class] forCellReuseIdentifier:kMessageCellIdentifier];
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.bounces = YES;
    self.keyboardPanningEnabled = YES;
    self.inverted = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 40, 0);
}

-(void)setUpCenterMeButton:(id)sender{
    self.centerMeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.centerMeButton setImage:[UIImage imageNamed:@"center_me_button"] forState:UIControlStateNormal];
    [self.centerMeButton addTarget:self action:@selector(centerMeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.centerMeButton aboveSubview:self.mapView];
}

-(void)setUpRemoveMeButton:(id)sender{
    self.removeMeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.removeMeButton setImage:[UIImage imageNamed:@"delete_button_icon"] forState:UIControlStateNormal];
    [self.removeMeButton addTarget:self action:@selector(removeMeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.removeMeButton aboveSubview:self.mapView];
}

-(void)setUpBellButton:(id)sender{
    self.bellButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.bellButton setImage:[UIImage imageNamed:@"bell_button_not_ringing"] forState:UIControlStateNormal];
    [self.bellButton addTarget:self action:@selector(bellButtonButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.bellButton aboveSubview:self.mapView];
}

-(void)setUpTableButton:(id)sender{
    self.tableButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.tableButton setImage:[UIImage imageNamed:@"table_button_icon"] forState:UIControlStateNormal];
    [self.tableButton addTarget:self action:@selector(tableButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.tableButton aboveSubview:self.mapView];
}

-(void)setUpMapButton:(id)sender{
    self.mapButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.mapButton setImage:[UIImage imageNamed:@"map_button_icon"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.mapButton aboveSubview:self.tableView];
}

-(void)setUpMenuButton:(id)sender{
    self.menuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.menuButton setImage:[UIImage imageNamed:@"menu_map_button"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.menuButton aboveSubview:self.mapView];
}

-(void)setUpSearchButton:(id)sender{
    self.searchButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.searchButton setImage:[UIImage imageNamed:@"map_search_button"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.searchButton aboveSubview:self.mapView];
}

-(void)setUpLocationUpdateButton:(id)sender{
    self.locationUpdateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.locationUpdateButton setImage:[UIImage imageNamed:@"location_update_button_off"] forState:UIControlStateNormal];
    [self.locationUpdateButton addTarget:self action:@selector(locationUpdateButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.locationUpdateButton aboveSubview:self.mapView];
    RACSignal *locationUpdateSignal = [[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCIsLocationUpdateOn] map:^id(id value) {
        return @([value boolValue]);
    }];
    RACSignal *autoUpdateSignalImageChange = [[locationUpdateSignal map:^id(id value) {
        if ([value boolValue]) {
            return [UIImage imageNamed:@"location_update_button_on"];
        }else{
            return [UIImage imageNamed:@"location_update_button_off"];
        }
    }] doNext:^(id x) {
        
    }];
    [self.locationUpdateButton rac_liftSelector:@selector(setImage:forState:) withSignals:autoUpdateSignalImageChange, [RACSignal return:@(UIControlStateNormal)], nil] ;
}

-(void)setUpChatPreviewView:(id)sender{
    self.chatPreviewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60.0)];
    self.chatPreviewView.backgroundColor = [UIColor colorWithHexString:@"#454545"];
    UIView *upperBorderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.chatPreviewView.frame.size.width, 1.0)];
    upperBorderView.backgroundColor = [UIColor whiteColor];
    [self.chatPreviewView addSubview:upperBorderView];
    UIView *bottomBorderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.chatPreviewView.frame.size.height -2, self.chatPreviewView.frame.size.width, 1.0)];
    bottomBorderView.backgroundColor = [UIColor whiteColor];
    [self.chatPreviewView addSubview:bottomBorderView];
    CAGradientLayer *leftShadow = [CAGradientLayer layer];
    leftShadow.frame = CGRectMake(0, 0, 100, self.chatPreviewView.frame.size.height);
    leftShadow.startPoint = CGPointMake(0, 0.5);
    leftShadow.endPoint = CGPointMake(1.0, 0.5);
    leftShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.4f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.chatPreviewView.layer addSublayer:leftShadow];
    CAGradientLayer *rightShadow = [CAGradientLayer layer];
    rightShadow.frame = CGRectMake(CGRectGetWidth(self.chatPreviewView.frame)-100.0, 0, 100, self.chatPreviewView.frame.size.height);
    rightShadow.startPoint = CGPointMake(1.0, 0.5);
    rightShadow.endPoint = CGPointMake(0, 0.5);
    rightShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.4f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [self.chatPreviewView.layer addSublayer:rightShadow];
    [self.view insertSubview:self.chatPreviewView aboveSubview:self.mapView];
    
    self.chatPreviewSpriteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 48)];
    self.chatPreviewSpriteImageView.layer.magnificationFilter = kCAFilterNearest;
    self.chatPreviewSpriteImageView.image = [UIImage imageNamed:@"sample_sprite"];
    [self.chatPreviewView addSubview:self.chatPreviewSpriteImageView];
    
    self.chatPreviewMessageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.chatPreviewMessageLabel.textColor = [UIColor lightGrayColor];
    self.chatPreviewMessageLabel.font = [UIFont fontWithName:kTrocchiFontName size:14.0];
    self.chatPreviewMessageLabel.textInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    self.chatPreviewMessageLabel.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    self.chatPreviewMessageLabel.layer.cornerRadius = 3.0f;
    self.chatPreviewMessageLabel.layer.masksToBounds = YES;
    self.chatPreviewMessageLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.chatPreviewMessageLabel.layer.borderWidth = 1.0f;
    self.chatPreviewMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.chatPreviewMessageLabel.numberOfLines = 0;
    self.chatPreviewMessageLabel.text = @"Hey what's going on everyone";
    
    [self.chatPreviewView addSubview:self.chatPreviewMessageLabel];
    
    self.chatPreviewNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.chatPreviewNameLabel.textColor = [UIColor whiteColor];
    self.chatPreviewNameLabel.text = @"Justin NBar";
    self.chatPreviewNameLabel.font = [UIFont fontWithName:kTrocchiFontName size:9.0];
    [self.chatPreviewView addSubview:self.chatPreviewNameLabel];
    
    self.chatPreviewTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.chatPreviewTimeLabel.textColor = [UIColor lightGrayColor];
    self.chatPreviewTimeLabel.text = @"2 min ago";
    self.chatPreviewTimeLabel.font = [UIFont fontWithName:kTrocchiFontName size:9.0];
    self.chatPreviewTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.chatPreviewView addSubview:self.chatPreviewTimeLabel];
    
    
    UITapGestureRecognizer *chatTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chatPreviewViewDidTap:)];
    [self.chatPreviewView addGestureRecognizer:chatTapped];
}

-(void)setUpWorldHolder:(id)sender{
    self.worldNameLabel = [[THLabel alloc]initWithFrame:CGRectMake(0, 0, 90, 20)];
    self.worldNameLabel.textColor = [UIColor whiteColor];
    self.worldNameLabel.font = [UIFont fontWithName:kTrocchiFontName size:14.0];
    self.worldNameLabel.strokeColor = [UIColor blackColor];
    self.worldNameLabel.strokeSize = 1.25;
    self.worldNameLabel.textAlignment = NSTextAlignmentRight;

    self.worldImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.worldImageView.layer.cornerRadius = self.worldImageView.frame.size.width / 2.0f;
    self.worldImageView.layer.masksToBounds = YES;
    self.worldImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.worldImageView.layer.borderWidth = 1.0;
    
    self.worldHolder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    [self.worldHolder addSubview:self.worldNameLabel];
    [self.worldHolder addSubview:self.worldImageView];
    [self.view insertSubview:self.worldHolder aboveSubview:self.mapView];
    
    UITapGestureRecognizer *tapWorldHolder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(worldHolderDidTap:)];
    self.worldHolder.userInteractionEnabled = YES;
    [self.worldHolder addGestureRecognizer:tapWorldHolder];
}

-(void)setUpLeftButton:(id)sender{
    [self.leftButton setImage:[UIImage imageNamed:@"chat_media_button"] forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor grayColor]];
}


-(void)setUpLayout:(id)sender{
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatPreviewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerMeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.locationUpdateButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.textInputbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatPreviewSpriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatPreviewMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatPreviewTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatPreviewNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.removeMeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.bellButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.worldHolder.translatesAutoresizingMaskIntoConstraints = NO;
    self.worldImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.worldNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{
                            @"view": self.view,
                            @"mapView": self.mapView,
                            @"tableView": self.tableView,
                            @"chatPreviewView": self.chatPreviewView,
                            @"centerMeButton": self.centerMeButton,
                            @"tableButton": self.tableButton,
                            @"mapButton": self.mapButton,
                            @"locationUpdateButton": self.locationUpdateButton,
                            @"menuButton": self.menuButton,
                            @"searchButton": self.searchButton,
                            @"removeMeButton": self.removeMeButton,
                            @"bellButton": self.bellButton,
                            @"textView": self.textView,
                            @"textInputBar": self.textInputbar,
                            @"chatPreviewSpriteImageView": self.chatPreviewSpriteImageView,
                            @"chatPreviewMessageLabel": self.chatPreviewMessageLabel,
                            @"chatPreviewTimeLabel": self.chatPreviewTimeLabel,
                            @"chatPreviewNameLabel": self.chatPreviewNameLabel,
                            @"worldHolder": self.worldHolder,
                            @"worldNameLabel": self.worldNameLabel,
                            @"worldImageView": self.worldImageView
                            };
    
    NSDictionary *metrics = @{
                              @"chatPreviewViewHeight": @60.0,
                              @"mainButtonLength": @33.0,
                              @"worldNameLabelLength": @90
                              };
    

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mapView]-0-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mapView]-0-|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[menuButton(40)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[menuButton(40)]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchButton(40)]-0-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[searchButton(40)]" options:0 metrics:metrics views:views]];

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[chatPreviewView]-0-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatPreviewView]-0-[textInputBar]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[tableButton(mainButtonLength)]-5-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableButton(mainButtonLength)]-5-[chatPreviewView]" options:0 metrics:metrics views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[mapButton(mainButtonLength)]-5-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mapButton(mainButtonLength)]-5-[textInputBar]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[locationUpdateButton(mainButtonLength)]-5-[chatPreviewView(<=chatPreviewViewHeight)]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[removeMeButton(mainButtonLength)]-5-[chatPreviewView]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bellButton(mainButtonLength)]-5-[chatPreviewView]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[centerMeButton(mainButtonLength)]-5-[locationUpdateButton(mainButtonLength)]-5-[removeMeButton(mainButtonLength)]-5-[bellButton(mainButtonLength)]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[centerMeButton(mainButtonLength)]-5-[chatPreviewView]" options:0 metrics:metrics views:views]];
    
    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[chatPreviewSpriteImageView(28)]-10-[chatPreviewMessageLabel]-|" options:0 metrics:metrics views:views]];
    
    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[chatPreviewTimeLabel(80)]-|" options:0 metrics:metrics views:views]];
    
    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatPreviewSpriteImageView]-15-[chatPreviewNameLabel]-|" options:0 metrics:metrics views:views]];
    
    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[chatPreviewSpriteImageView(42)]" options:0 metrics:metrics views:views]];

    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[chatPreviewNameLabel(10)]-5-[chatPreviewMessageLabel]-7-|" options:0 metrics:metrics views:views]];
    
    [self.chatPreviewView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[chatPreviewTimeLabel(10)]" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[menuButton]-5-[worldHolder]-10-[searchButton]" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[worldHolder(==40)]" options:0 metrics:metrics views:views]];

    [self.worldHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[worldNameLabel]-[worldImageView(30)]-5-|" options:0 metrics:metrics views:views]];
    [self.worldHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[worldImageView(30)]" options:0 metrics:metrics views:views]];
    
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.worldHolder
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.searchButton
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    [self.worldHolder addConstraint:
     [NSLayoutConstraint constraintWithItem:self.worldImageView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.worldHolder
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    [self.worldHolder addConstraint:
     [NSLayoutConstraint constraintWithItem:self.worldNameLabel
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.worldHolder
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    

}

@end

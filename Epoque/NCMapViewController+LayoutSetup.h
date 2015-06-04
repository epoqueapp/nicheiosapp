//
//  NCMapViewController+LayoutSetup.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController.h"

@interface NCMapViewController (LayoutSetup)

-(void)setUpTextView:(id)sender;

-(void)setUpMapView:(id)sender;
-(void)setUpTableView:(id)sender;

-(void)setUpWorldHolder:(id)sender;

-(void)setUpLocationUpdateButton:(id)sender;
-(void)setUpCenterMeButton:(id)sender;
-(void)setUpMenuButton:(id)sender;
-(void)setUpSearchButton:(id)sender;
-(void)setUpMapButton:(id)sender;
-(void)setUpTableButton:(id)sender;
-(void)setUpBellButton:(id)sender;
-(void)setUpRemoveMeButton:(id)sender;
-(void)setUpChatPreviewView:(id)sender;
-(void)setUpLayout:(id)sender;
-(void)setUpRightButton:(id)sender;
-(void)setUpLeftButton:(id)sender;

@end

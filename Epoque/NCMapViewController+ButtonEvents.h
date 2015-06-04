//
//  NCMapViewController+ButtonEvents.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController.h"

@interface NCMapViewController (ButtonEvents)

-(void)menuButtonDidTap:(id)sender;
-(void)centerMeButtonDidTap:(id)sender;
-(void)locationUpdateButtonDidTap:(id)sender;
-(void)searchButtonDidClick:(id)sender;
-(void)chatPreviewViewDidTap:(id)sender;
-(void)mapButtonDidTap:(id)sender;
-(void)tableButtonDidTap:(id)sender;
-(void)removeMeButtonDidTap:(id)sender;
-(void)bellButtonButtonDidTap:(id)sender;
-(void)worldHolderDidTap:(id)sender;

@end

//
//  NCWorldChatViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "SLKTextViewController.h"
#import "WorldModel.h"
#import <MapKit/MapKit.h>

@interface NCWorldChatViewController : SLKTextViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) WorldModel *worldModel;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

+(id)sharedInstance;

@end

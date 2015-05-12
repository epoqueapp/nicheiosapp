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
#import "NCHeartDelegate.h"
#import "NCTableSpriteDelegate.h"
#import "NCMessageNameLabelDelegate.h"
@interface NCWorldChatViewController : SLKTextViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, TTTAttributedLabelDelegate, NCHeartDelegate, NCTableSpriteDelegate, NCMessageNameLabelDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIButton *centerMeButton;
@property (nonatomic, strong) UIButton *updateLocationButton;
@property (nonatomic, strong) UITextField *obscurityTextField;

@property (nonatomic, strong) UIImageView *emblemImageView;

+(id)sharedInstance;

@end

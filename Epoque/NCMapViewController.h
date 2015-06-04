//
//  NCWorldMapViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UserAnnotationView.h"
#import "SLKTextViewController.h"
#import "WorldModel.h"
#import "SendMessageModel.h"
#import "MKMapView+Utilities.h"
#import "NCMessageTableViewCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <WYPopoverController/WYPopoverController.h>
#import "NCAttachmentPhoto.h"
static NSString *const kCameraTitle = @"Camera";
static NSString *const kGalleryTitle = @"Gallery";
static NSString *const kPlaceTitle = @"Plop A Place";
static NSString *const kMessageCellIdentifier = @"kMessageCellIdentifier";
static NSString *const kBlockUserTitle = @"Block User";
static NSString *const kConfirmBlockUserTitle = @"Yes User";
static NSString *const kReportUserTitle = @"Report User";
static NSString *const kRemoveMeConfirmTitle = @"Yes, Remove Me";

static NSString *const kViewWorldUsersTitle = @"See World Members";
static NSString *const kViewWorldDetailsTitle = @"See World Info";
static NSString *const kFavoriteWorldTitle = @"Favorite World";
static NSString *const kUnfavoriteWorldTitle = @"Unfavorite World";
static NSString *const kEditWorldTitle = @"Edit World";
static NSString *const kLeaveWorldTitle = @"Leave World";



@interface NCMapViewController : SLKTextViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NCMessageTableViewCellDelegate>

@property (nonatomic, strong) NSMutableDictionary *userAnnotations;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *chatPreviewView;
@property (nonatomic, strong) UIImageView *chatPreviewSpriteImageView;
@property (nonatomic, strong) TTTAttributedLabel *chatPreviewMessageLabel;
@property (nonatomic, strong) UILabel *chatPreviewNameLabel;
@property (nonatomic, strong) UILabel *chatPreviewTimeLabel;
@property (nonatomic, copy) NSString *chatPreviewUserId;


@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, strong) THLabel *worldNameLabel;
@property (nonatomic, strong) UIImageView *worldImageView;
@property (nonatomic, strong) UIView *worldHolder;
@property (nonatomic, strong) WorldModel *worldModel;

@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *centerMeButton;
@property (nonatomic, strong) UIButton *locationUpdateButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UIButton *tableButton;
@property (nonatomic, strong) UIButton *removeMeButton;
@property (nonatomic, strong) UIButton *bellButton;

@property (nonatomic, copy) NSString *userIdToBlock;
@property (nonatomic, copy) NSString *userIdToReport;

@property (nonatomic, strong) NCSoundEffect *tableShoutSoundEffect;
@property (nonatomic, strong) NCSoundEffect *mapShoutSoundEffect;
@property (nonatomic, strong) NCSoundEffect *centerSoundEffect;

@property (nonatomic, assign) BOOL isListening;

-(void)sendMessage:(SendMessageModel *)sendMessageModel;

-(void)clearMap;

-(id)initWithWorldId:(NSString *)worldId;

@end

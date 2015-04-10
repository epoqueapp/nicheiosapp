//
//  NCWorldMapViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SLKTextViewController.h"
#import "WorldModel.h"
@interface NCMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, strong) SLKTextInputbar *textInputbar;
@property (nonatomic, strong) SLKTextView *textView;

@end

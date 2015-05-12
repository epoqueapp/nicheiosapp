//
//  UserAnnotation.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>

#define kNCUserAnnotationIdentifier @"kNCUserAnnotationIdentifier"

@interface UserAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userSpriteUrl;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userImageUrl;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSString *messageImageUrl;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL isObscuring;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

-(id)initWithSnapshot:(FDataSnapshot *)snapshot;

-(void)upsertFromSnapshot:(FDataSnapshot *)snapshot;

@end

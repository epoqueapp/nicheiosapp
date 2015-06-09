//
//  BlurbAnnotation.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/Mapkit.h>
@interface BlurbAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *blurbId;
@property (nonatomic, strong) NSString *spriteUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *websiteUrl;
@property (nonatomic, strong) NSString *worldId;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

-(id)initWithSnapshot:(FDataSnapshot *)snapshot;

-(void)upsertFromSnapshot:(FDataSnapshot *)snapshot;

@end

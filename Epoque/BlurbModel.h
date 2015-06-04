//
//  BlurbModel.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"

@interface BlurbModel : JSONModel

@property (nonatomic, strong) NSString *blurbId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D geo;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *spriteImageUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *creatorUserId;

-(id)initWithSnapshot:(FDataSnapshot *)snapshot;

@end

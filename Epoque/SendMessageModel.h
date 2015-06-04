//
//  SendMessageModel.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"
#import <CoreLocation/CoreLocation.h>
@interface SendMessageModel : JSONModel

@property (nonatomic, strong) NSString *worldId;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSString *messageImageUrl;
@property (nonatomic, strong) NSString *messageVideoUrl;

@property (nonatomic, strong) CLLocation *location;


@end

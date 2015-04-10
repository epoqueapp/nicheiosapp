//
//  WorldModel.h
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <JSONModel/JSONModel.h>

@protocol WorldModel

@end

@interface WorldModel : JSONModel

@property (nonatomic, copy) NSString *worldId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, copy) NSArray *memberUserIds;
@property (nonatomic, copy) NSArray *moderatorUserIds;


-(id)initWithSnapshot:(FDataSnapshot *)snapshot;
-(BOOL)belongsToWorld:(NSString *)userId;

@end

//
//  WorldResultsModel.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"
#import "WorldModel.h"
@interface WorldResultsModel : JSONModel

@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, strong) NSArray<WorldModel> *worlds;

@end

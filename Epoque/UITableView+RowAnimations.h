//
//  UITableView+RowAnimations.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/16/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (RowAnimations)

-(void)insertRowsAtIndexPathsWithEpoqueAnimation:(NSArray *)indexPaths;

@end

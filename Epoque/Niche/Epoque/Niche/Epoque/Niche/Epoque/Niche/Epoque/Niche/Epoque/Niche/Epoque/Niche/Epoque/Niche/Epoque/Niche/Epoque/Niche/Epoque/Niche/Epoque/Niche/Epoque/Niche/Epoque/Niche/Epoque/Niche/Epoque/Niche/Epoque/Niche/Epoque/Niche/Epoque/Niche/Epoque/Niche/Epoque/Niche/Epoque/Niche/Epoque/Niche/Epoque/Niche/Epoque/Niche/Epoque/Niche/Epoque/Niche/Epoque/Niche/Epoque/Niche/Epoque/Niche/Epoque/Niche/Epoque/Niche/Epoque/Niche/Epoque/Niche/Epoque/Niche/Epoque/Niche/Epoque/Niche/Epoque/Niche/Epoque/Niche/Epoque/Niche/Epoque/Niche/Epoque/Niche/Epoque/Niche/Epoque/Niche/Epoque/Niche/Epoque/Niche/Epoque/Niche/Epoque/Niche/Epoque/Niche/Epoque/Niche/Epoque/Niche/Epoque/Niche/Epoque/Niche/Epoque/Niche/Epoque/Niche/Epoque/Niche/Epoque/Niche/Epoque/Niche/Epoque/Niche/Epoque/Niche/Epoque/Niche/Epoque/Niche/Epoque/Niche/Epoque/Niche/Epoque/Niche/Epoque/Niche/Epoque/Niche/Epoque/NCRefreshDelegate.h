//
//  NCRefreshDelegate.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NCRefreshDelegate <NSObject>

@optional
-(void)shouldRefresh:(id)sender;

@end

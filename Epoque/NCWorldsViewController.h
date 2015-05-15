//
//  NCWorldsViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCCreateNewWorldViewController.h"

@interface NCWorldsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NCRefreshDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *clockImageView;
@property (nonatomic, weak) IBOutlet UIImageView *minuteImageView;
@property (nonatomic, weak) IBOutlet UIImageView *hourImageView;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

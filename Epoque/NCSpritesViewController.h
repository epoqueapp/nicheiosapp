//
//  NCSpritesViewController.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NCSpritesViewControllerDelegate <NSObject>

@optional
-(void)didSelectSpriteFromModal:(NSString *)spriteUrl;

@end


@interface NCSpritesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) id<NCSpritesViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIImageView *clockImageView;
@property (nonatomic, weak) IBOutlet UIImageView *minuteImageView;
@property (nonatomic, weak) IBOutlet UIImageView *hourImageView;

@end

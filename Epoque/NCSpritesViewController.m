//
//  NCSpritesViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import <MBFaker/MBFaker.h>
#import "NCSpritesViewController.h"
#import "EPSpriteService.h"
#import "NCSpriteCollectionViewCell.h"
#import "NCWorldsViewController.h"
#import "NCFireService.h"
#import "NCNameChoiceViewController.h"
@interface NCSpritesViewController ()

@end

static NSString* const CellIdentifier = @"Cell";

@implementation NCSpritesViewController{
    EPSpriteService *spritesService;
    NSArray *maleSprites;
    NSArray *femaleSprites;
    NCFireService *fireService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"NCSpriteCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellIdentifier];
    spritesService = [EPSpriteService sharedInstance];
    maleSprites = [NSArray array];
    femaleSprites = [NSArray array];
    fireService = [NCFireService sharedInstance];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    @weakify(self);
    [[[spritesService getSprites] retry:100] subscribeNext:^(id x) {
        @strongify(self);
        maleSprites = [x objectForKey:@"male"];
        femaleSprites = [x objectForKey:@"female"];
        [self fadeOutHands:self];
    } error:^(NSError *error) {
        @strongify(self);
        [self fadeOutHands:self];
        [[[UIAlertView alloc]initWithTitle:@"Oops" message:@"There was an issue fetching the sprites" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    } completed:^{
        @strongify(self);
        [self.collectionView reloadData];
    }];
    
    self.backgroundImageView.alpha = 0;
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/epoque-wallpapers/dark-wood.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        [UIView animateWithDuration:1.0 animations:^{
            self.backgroundImageView.alpha = 1;
        }];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self spinHands:self];
}

-(void)spinHands:(id)sender{
    [self.hourImageView runSpinAnimationWithDuration:3.0 isClockwise:YES];
    [self.minuteImageView runSpinAnimationWithDuration:4.0 isClockwise:NO];
}

-(void)fadeOutHands:(id)sender{
    @weakify(self);
    [UIView animateWithDuration:2.0 animations:^{
        @strongify(self);
        self.hourImageView.alpha = 0.0;
        self.minuteImageView.alpha = 0;
        self.clockImageView.alpha = 0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return maleSprites.count;
    }else{
        return femaleSprites.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *spriteUrl;
    NSString *gender;
    if (indexPath.section == 0) {
        spriteUrl = [maleSprites objectAtIndex:indexPath.row];
        gender = @"Male Sprite";
    }else{
        spriteUrl = [femaleSprites objectAtIndex:indexPath.row];
        gender = @"Female Sprite";
    }
    NCSpriteCollectionViewCell *cell = (NCSpriteCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.spriteImageView.alpha = 0;
    cell.spriteImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:spriteUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.spriteImageView.alpha = 0.0;
        float duration = [NCNumberHelper randomFloatBetweenMinRange:0.50 maxRange:1.00];
        [UIView animateWithDuration:duration
                         animations:^{
                             cell.spriteImageView.alpha = 1.0;
                             cell.spriteImageView.transform = CGAffineTransformIdentity;
                         }];
    }];
    cell.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSString *spriteUrl;
    if (indexPath.section == 0) {
        spriteUrl = [maleSprites objectAtIndex:indexPath.row];
    }else{
        spriteUrl = [femaleSprites objectAtIndex:indexPath.row];
    }
    [Amplitude logEvent:@"Selected Sprite" withEventProperties:@{@"spriteUrl": spriteUrl}];
    [[NSUserDefaults standardUserDefaults] setWelcomeSpriteUrl:spriteUrl];
    if ([self.delegate respondsToSelector:@selector(didSelectSpriteFromModal:)]) {
        [self.delegate didSelectSpriteFromModal:spriteUrl];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NCNameChoiceViewController *nameChoice = [[NCNameChoiceViewController alloc]init];
        nameChoice.spriteUrl = [spriteUrl copy];
        [self.navigationController pushFadeViewController:nameChoice];
    }
}



@end

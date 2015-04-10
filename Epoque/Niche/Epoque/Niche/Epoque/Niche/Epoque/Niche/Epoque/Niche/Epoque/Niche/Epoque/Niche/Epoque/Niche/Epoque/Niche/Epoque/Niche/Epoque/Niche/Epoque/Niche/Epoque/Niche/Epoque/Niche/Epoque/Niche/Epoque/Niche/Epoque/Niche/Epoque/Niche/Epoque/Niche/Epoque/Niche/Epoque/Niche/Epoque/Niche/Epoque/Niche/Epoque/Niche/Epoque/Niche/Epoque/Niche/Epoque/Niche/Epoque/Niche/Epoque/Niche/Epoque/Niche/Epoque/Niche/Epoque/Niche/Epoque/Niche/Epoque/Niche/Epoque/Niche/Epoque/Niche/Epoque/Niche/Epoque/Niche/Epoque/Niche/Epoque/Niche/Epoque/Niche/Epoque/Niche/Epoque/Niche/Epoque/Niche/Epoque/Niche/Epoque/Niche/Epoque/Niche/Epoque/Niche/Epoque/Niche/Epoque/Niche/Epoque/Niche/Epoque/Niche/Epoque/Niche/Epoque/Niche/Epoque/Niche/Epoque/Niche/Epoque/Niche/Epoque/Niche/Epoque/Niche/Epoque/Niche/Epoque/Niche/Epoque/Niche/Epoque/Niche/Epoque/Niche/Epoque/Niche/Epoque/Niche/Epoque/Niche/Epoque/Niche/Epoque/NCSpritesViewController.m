//
//  NCSpritesViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCSpritesViewController.h"
#import "EPSpriteService.h"
#import "NCSpriteCollectionViewCell.h"
#import "NCCreateUserViewController.h"
#import "NCFacebookLoginViewController.h"

@interface NCSpritesViewController ()

@end

static NSString* const CellIdentifier = @"Cell";

@implementation NCSpritesViewController{
    EPSpriteService *spritesService;
    NSArray *maleSprites;
    NSArray *femaleSprites;
    Mixpanel *mixpanel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"NCSpriteCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellIdentifier];
    
    mixpanel = [Mixpanel sharedInstance];
    spritesService = [EPSpriteService sharedInstance];
    maleSprites = [NSArray array];
    femaleSprites = [NSArray array];
    
    @weakify(self);
    [mixpanel timeEvent:@"Get Sprites"];
    [[spritesService getSprites] subscribeNext:^(id x) {
        [mixpanel track:@"Get Sprites"];
        maleSprites = [x objectForKey:@"male"];
        femaleSprites = [x objectForKey:@"female"];
    } error:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"Oops" message:@"There was an issue fetching the sprites" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    } completed:^{
        @strongify(self);
        [self.collectionView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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
    [[NSUserDefaults standardUserDefaults]setWelcomeSpriteUrl:spriteUrl];
    if ([self.delegate respondsToSelector:@selector(didSelectSpriteFromModal:)]) {
        [self.delegate didSelectSpriteFromModal:spriteUrl];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NCFacebookLoginViewController *facebookLoginViewController = [[NCFacebookLoginViewController alloc]init];
        facebookLoginViewController.spriteUrl = [spriteUrl copy];
        [self.navigationController pushViewController:facebookLoginViewController animated:YES];
    }
}



@end

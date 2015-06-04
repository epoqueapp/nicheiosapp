//
//  NCWorldTableViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldTableViewCell.h"

@implementation NCWorldTableViewCell{
    RACDisposable *worldDisposable;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    
    self.worldImageView.layer.masksToBounds = YES;
    self.worldImageView.layer.cornerRadius = self.worldImageView.frame.size.width / 2.0;
    self.worldImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.worldImageView.layer.borderWidth = 1.5;
    
    self.worldNameLabel.textColor = [UIColor lightGrayColor];
}


-(void)prepareForReuse{
    self.firstIconImageView.image = nil;
    self.secondIconImageView.image = nil;
    self.thirdIconImageView.image = nil;
    [worldDisposable dispose];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setWorldModel:(WorldModel *)worldModel{
    [self.worldImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
    self.worldNameLabel.text = worldModel.name;
    
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSMutableArray *iconImages = [NSMutableArray array];
    
    BOOL isDefault = worldModel.isDefault;
    if (isDefault) {
        [iconImages addObject:[UIImage imageNamed:@"fire_icon"]];
    }
    
    BOOL isFavorite = [worldModel.favoritedUserIds containsObject:myUserId];
    if (isFavorite) {
        [iconImages addObject:[UIImage imageNamed:@"star_icon"]];
    }
    
    BOOL isPrivateAndUnauthorized = ![worldModel.memberUserIds containsObject:myUserId] && worldModel.isPrivate;
    BOOL isPrivateAndAuthorized = [worldModel.memberUserIds containsObject:myUserId] && worldModel.isPrivate;
    if(isPrivateAndAuthorized){
        [iconImages addObject:[UIImage imageNamed:@"unlock_icon_purple"]];
    }
    if(isPrivateAndUnauthorized){
        [iconImages addObject:[UIImage imageNamed:@"key_icon_purple"]];
    }
    
    for (int i = 0; i < iconImages.count; i++) {
        UIImage *image = [iconImages objectAtIndex:i];
        
        
        if (i == 0) {
            self.firstIconImageView.image = image;
        }
        if (i == 1) {
            self.secondIconImageView.image = image;
        }
        if (i == 2) {
            self.thirdIconImageView.image = image;
        }
    }
    [worldDisposable dispose];
    @weakify(self);
    worldDisposable = [[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:kNCCurrentWorldId] map:^id(id value) {
        return @([value isEqualToString:worldModel.worldId.copy]);
    }] subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            self.backgroundColor = [UIColor colorWithHexString:@"#3D3D3D"];
        }else{
            self.backgroundColor = [UIColor clearColor];
        }
    }];
    
}

@end

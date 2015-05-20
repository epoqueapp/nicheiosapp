//
//  NCWorldTableViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldTableViewCell.h"

@implementation NCWorldTableViewCell{
    FirebaseHandle handle;
    Firebase *ref;
}

- (void)awakeFromNib {
    // Initialization code
    self.nameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:14.0];
    self.nameLabel.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.7];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.nameLabel.layer.cornerRadius = 3.0f;
    self.nameLabel.layer.masksToBounds = YES;
    
    
    self.worldImageView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.worldImageView.layer.cornerRadius = 3.0f;
    self.worldImageView.layer.masksToBounds = YES;
    
    self.badgeLabel.backgroundColor = [UIColor redColor];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.layer.cornerRadius = self.badgeLabel.frame.size.width / 2.0;
    self.badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.badgeLabel.layer.borderWidth = 0.5f;
    self.badgeLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setWorldId:(NSString *)worldId{
    _worldId = worldId;
    if (handle) {
        [ref removeObserverWithHandle:handle];
    }
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    ref = [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"user-notification-badges"] childByAppendingPath:myUserId] childByAppendingPath:@"world-messages"] childByAppendingPath:worldId];
    @weakify(self);
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (![snapshot.value isKindOfClass:[NSNull class]]) {
            NSInteger count = [snapshot.value integerValue];
            self.badgeLabel.text = [snapshot.value stringValue];
            if (count <= 0) {
                self.badgeLabel.hidden = YES;
            }else{
                self.badgeLabel.hidden = NO;
            }
        }else{
            self.badgeLabel.hidden = YES;
        }
    }];
}

@end

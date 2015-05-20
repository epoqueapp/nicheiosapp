//
//  NCWorldCollectionViewCell.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/15/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldCollectionViewCell.h"

@implementation NCWorldCollectionViewCell {
    FirebaseHandle handle;
    Firebase *ref;
}

- (void)awakeFromNib {
    // Initialization code
    self.worldNameLabel.strokeColor = [UIColor blackColor];
    self.worldNameLabel.strokeSize = 1.25;
    self.worldNameLabel.textColor = [UIColor whiteColor];
    self.worldNameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:12.0];
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    self.keyImageView.layer.shadowColor = [UIColor purpleColor].CGColor;
    self.keyImageView.layer.shadowOffset = CGSizeMake(0, 1);
    self.keyImageView.layer.shadowOpacity = 1;
    self.keyImageView.layer.shadowRadius = 1.0;
    self.keyImageView.clipsToBounds = NO;
    
    self.notificationLabel.backgroundColor = [UIColor redColor];
    self.notificationLabel.layer.masksToBounds = YES;
    self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.width / 2.0;
    self.notificationLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.notificationLabel.layer.borderWidth = 1.0f;
    self.notificationLabel.textColor = [UIColor whiteColor];
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
                self.notificationLabel.text = [snapshot.value stringValue];
                if (count <= 0) {
                    self.notificationLabel.hidden = YES;
                }else{
                    self.notificationLabel.hidden = NO;
                }
            }else{
                self.notificationLabel.hidden = YES;
            }
        }];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
}

@end

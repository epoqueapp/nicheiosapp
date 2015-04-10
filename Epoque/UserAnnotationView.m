//
//  UserAnnotationView.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UserAnnotationView.h"

@implementation UserAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 60, 60);
        [self setupPlateImageView];
        [self setupSpriteImageView];
        [self setupShoutRings];
        [self setUpShoutBubbleAndLabel];
        [self setUpMediaBubble];
        @weakify(self);
        [RACObserve(self, userAnnotation) subscribeNext:^(UserAnnotation *userAnnotation) {
            @strongify(self);
            [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userAnnotation.userSpriteUrl]];
        
            if ([userAnnotation.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
                self.plateImageView.hidden = NO;
            }else{
                self.plateImageView.hidden = YES;
            }
            
            NSString *messageText = userAnnotation.messageText;
            if (![NSString isStringEmpty:messageText]) {
                NSString *formattedMessageText = [userAnnotation.messageText stringByAppendingString:@" "];
                [self.shoutLabel setText:formattedMessageText];
                self.shoutLabel.hidden = NO;
                self.shoutBubbleImageView.hidden = NO;
            }else{
                self.shoutLabel.hidden = YES;
                self.shoutBubbleImageView.hidden = YES;
            }
            
            NSString *imageUrl = userAnnotation.messageImageUrl;
            if (![NSString isStringEmpty:imageUrl]) {
                self.mediaBubbleImageView.hidden = NO;
            }else{
                self.mediaBubbleImageView.hidden = YES;
            }
            
        }];
    }
    return self;
}

-(void)setupPlateImageView{
    self.plateImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"plate"]];
    self.plateImageView.frame = CGRectMake(0, 0, 60, 60);
    self.plateImageView.layer.magnificationFilter = kCAFilterNearest;
    self.plateImageView.center = self.center;
    self.plateImageView.frame = CGRectOffset(self.frame, 0, 20);
    [self addSubview:self.plateImageView];
}

-(void)setupSpriteImageView{
    self.spriteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
    self.spriteImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.spriteImageView.center = self.center;
    [self addSubview:self.spriteImageView];
}

-(void)setupShoutRings{
    self.shoutRings = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIView *shoutRing = [[UIView alloc]initWithFrame:self.frame];
        shoutRing.backgroundColor = [UIColor clearColor];
        shoutRing.layer.cornerRadius = 30.0;
        shoutRing.layer.borderColor = [UIColor darkGrayColor].CGColor;
        shoutRing.layer.borderWidth = 1.5f;
        shoutRing.alpha = 0;
        [self.shoutRings addObject:shoutRing];
        [self addSubview:shoutRing];
    }
}

-(void)setUpShoutBubbleAndLabel{
    self.shoutBubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-60, -20, 150, 38)];
    self.shoutBubbleImageView.image = [UIImage imageNamed:@"shout_bubble_dark_gradient"];
    [self addSubview:self.shoutBubbleImageView];
    
    self.shoutLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(-52, -23, 130, 30)];
    self.shoutLabel.font = [UIFont fontWithName:kTrocchiFontName size:16.0];
    self.shoutLabel.textColor = [UIColor whiteColor];
    self.shoutLabel.marqueeType = MLContinuous;
    self.shoutLabel.rate = 30.0f;
    self.shoutLabel.text = @"Something rather interesting";
    [self addSubview:self.shoutLabel];
}

-(void)setUpMediaBubble{
    self.mediaBubbleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, -45, 60, 60)];
    self.mediaBubbleImageView.image = [UIImage imageNamed:@"media_bubble"];
    [self addSubview:self.mediaBubbleImageView];
}

-(void)animateRings{
    [self animateRingsWithColor:[UIColor blackColor]];
}

-(void)animateRingsWithColor:(UIColor *)color{
    for (int i = 0; i < self.shoutRings.count; i++) {
        UIView *shoutRing = [self.shoutRings objectAtIndex:i];
        shoutRing.layer.borderColor = color.CGColor;
        [UIView animateWithDuration:0.20 animations:^{
            shoutRing.alpha = 1;
        }];
        
        [UIView animateWithDuration:0.70 delay:(i * 0.10) options:UIViewAnimationOptionCurveEaseInOut animations:^{
            shoutRing.transform = CGAffineTransformMakeScale(3, 3);
            shoutRing.alpha = 0;
        } completion:^(BOOL finished) {
            shoutRing.transform = CGAffineTransformIdentity;
            shoutRing.alpha = 0;
        }];
    }
}

@end

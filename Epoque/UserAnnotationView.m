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
        [self setUpCenterRing];
        [self setUpShoutBubbleAndLabel];
        [self setUpMediaBubble];
        @weakify(self);
        [RACObserve(self, userAnnotation) subscribeNext:^(UserAnnotation *userAnnotation) {
            @strongify(self);
            [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userAnnotation.userSpriteUrl]];
            if ([userAnnotation.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
                self.plateImageView.hidden = NO;
                self.shoutBubbleImageView.image = [UIImage imageNamed:@"shout_bubble_blue_gradient"];
            }else{
                self.plateImageView.hidden = YES;
                self.shoutBubbleImageView.image = [UIImage imageNamed:@"shout_bubble_dark_gradient"];
            }
            NSString *messageText = userAnnotation.messageText;
            if (![NSString isStringEmpty:messageText] && ![self isOld:userAnnotation.timestamp]) {
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
            
            if ([self isStale:userAnnotation.timestamp]) {
                self.layer.opacity = 0.5;
            }
            /*if([self isAncient:userAnnotation.timestamp]){
                self.layer.opacity = 0;
            }*/
            if ([self isFresh:userAnnotation.timestamp]) {
                self.layer.opacity = 1;
            }
        }];
    }
    return self;
}

-(BOOL)isFresh:(NSDate *)date{
    NSInteger hours = [self hoursBetween:date and:[NSDate date]];
    return hours < 3;
}


-(BOOL)isOld:(NSDate *)date{
    NSInteger hours = [self hoursBetween:date and:[NSDate date]];
    return hours > 3;
}

-(BOOL)isStale:(NSDate *)date{
    NSInteger hours = [self hoursBetween:date and:[NSDate date]];
    return hours > 6;
}

-(BOOL)isAncient:(NSDate *)date{
    NSInteger hours = [self hoursBetween:date and:[NSDate date]];
    return hours > 36;
}

- (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSCalendarUnitHour;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (firstDate == nil) {
        firstDate = [NSDate date];
    }
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]+1;
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

-(void)setUpCenterRing{
    self.centerRing = [[UIView alloc]initWithFrame:self.frame];
    self.centerRing.backgroundColor = [UIColor clearColor];
    self.centerRing.layer.cornerRadius = 30.0;
    self.centerRing.layer.borderColor = [UIColor blueColor].CGColor;
    self.centerRing.layer.borderWidth = 1.5f;
    self.centerRing.alpha = 0;
    [self addSubview:self.centerRing];
}

-(void)setupShoutRings{
    self.shoutRings = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIView *shoutRing = [[UIView alloc]initWithFrame:self.frame];
        shoutRing.backgroundColor = [UIColor clearColor];
        shoutRing.layer.cornerRadius = 30.0;
        shoutRing.layer.borderColor = [UIColor blueColor].CGColor;
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

-(void)animateCenterRing{
    [self animateCenterRing:[UIColor blueColor]];
}

-(void)animateCenterRing:(UIColor *)color {
    self.centerRing.layer.borderColor = color.CGColor;
    self.centerRing.alpha = 1;
        self.centerRing.transform = CGAffineTransformIdentity;
    self.centerRing.transform = CGAffineTransformMakeScale(3, 3);

    [UIView animateWithDuration:0.7 animations:^{
        self.centerRing.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.centerRing.alpha = 0;
    } completion:^(BOOL finished) {
        self.centerRing.transform = CGAffineTransformIdentity;
        self.centerRing.alpha = 0;
    }];
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

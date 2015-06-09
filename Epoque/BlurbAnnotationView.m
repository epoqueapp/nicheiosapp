//
//  BlurbAnnotationView.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "BlurbAnnotationView.h"

@implementation BlurbAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.blurbAnnotation = (BlurbAnnotation *)annotation;
        CGRect frame = CGRectMake(0, 0, 100, 100);
        self.frame = frame;
        self.spriteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
        self.spriteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.spriteImageView];
        self.spriteImageView.center = self.center;
        @weakify(self);
        [[RACSignal merge:@[RACObserve(self, blurbAnnotation), RACObserve(self, annotation)]] subscribeNext:^(BlurbAnnotation *x) {
            @strongify(self);
            [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:x.spriteUrl]];
        }];
    }
    return self;
}




@end

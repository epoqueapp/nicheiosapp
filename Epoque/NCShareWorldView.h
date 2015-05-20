//
//  NCShareWorldView.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/16/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THLabel/THLabel.h>
@interface NCShareWorldView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *worldImageView;
@property (nonatomic, weak) IBOutlet THLabel *linkLabel;
@property (nonatomic, weak) IBOutlet THLabel *pinLabel;
@property (nonatomic, weak) IBOutlet THLabel *secretLabel;
@property (nonatomic, weak) IBOutlet THLabel *worldNameLabel;

-(void)setPINWithString:(NSString *)pinString;

+(NCShareWorldView *)generateView;
-(UIImage *)toImage;

@end

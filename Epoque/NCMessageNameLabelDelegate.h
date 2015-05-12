//
//  NCMessageNameLabelDelegate.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/12/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NCMessageNameLabelDelegate <NSObject>

-(void)tappedNameLabel:(NSIndexPath *)indexPath;

@end

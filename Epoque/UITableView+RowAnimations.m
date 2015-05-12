//
//  UITableView+RowAnimations.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/16/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UITableView+RowAnimations.h"
#import "NCMessageTableViewCell.h"
@implementation UITableView (RowAnimations)

- (void)insertRowsAtIndexPathsWithEpoqueAnimation:(NSArray *)indexPaths{
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates]; // Populates UITableView with data
    [self beginUpdates];
    for (NSIndexPath *indexPath in indexPaths) {
        __block UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell) { // If indexPath isn't visible we'll get nil here
            // Custom animation
            CGRect frame = cell.frame;
            frame.origin.x = cell.frame.size.width;
            cell.frame = frame;
            frame.origin.x = 0;
            
            cell.backgroundColor = [UIColor lovelyBlue];
            void (^animationsBlock)() = ^{
                cell.frame = frame;
                cell.backgroundColor = [UIColor clearColor];
            };
            if ([[UIView class] respondsToSelector:
                 @selector(animateWithDuration:delay:usingSpringWithDamping:
                           initialSpringVelocity:options:animations:completion:)]) {
                     [UIView animateWithDuration:0.3
                                           delay:0
                          usingSpringWithDamping:0.5
                           initialSpringVelocity:0
                                         options:0
                                      animations:animationsBlock
                                      completion:NULL];
                 } else {
                     [UIView animateWithDuration:0.3
                                           delay:0
                                         options:UIViewAnimationOptionCurveEaseIn
                                      animations:animationsBlock
                                      completion:NULL];
                 }
        }
    }
}

@end

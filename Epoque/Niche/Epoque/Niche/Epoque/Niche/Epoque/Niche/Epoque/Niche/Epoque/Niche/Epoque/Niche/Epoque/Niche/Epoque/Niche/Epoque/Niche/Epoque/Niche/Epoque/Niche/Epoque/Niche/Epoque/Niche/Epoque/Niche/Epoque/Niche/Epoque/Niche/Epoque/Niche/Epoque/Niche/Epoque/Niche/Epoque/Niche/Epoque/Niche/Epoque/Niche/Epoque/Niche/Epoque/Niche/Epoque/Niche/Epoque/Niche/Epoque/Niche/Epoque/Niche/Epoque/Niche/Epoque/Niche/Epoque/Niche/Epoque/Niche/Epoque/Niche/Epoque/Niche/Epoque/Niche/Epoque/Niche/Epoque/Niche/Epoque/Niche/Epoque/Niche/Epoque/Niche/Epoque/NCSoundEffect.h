//
//  NCSoundEffect.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface NCSoundEffect : NSObject

{
    SystemSoundID soundID;
}

- (id)initWithSoundNamed:(NSString *)filename;
- (void)play;

@end

//
//  NCSoundEffect.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/6/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCSoundEffect.h"

@implementation NCSoundEffect

- (id)initWithSoundNamed:(NSString *)filename
{
    if ((self = [super init]))
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil)
        {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError)
                soundID = theSoundID;
        }
    }
    return self;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)play
{
    AudioServicesPlaySystemSound(soundID);
}

@end

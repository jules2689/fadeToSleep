//
//  AppDelegate.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "AppDelegate.h"
#import "ANSystemSoundWrapper.h"

@implementation AppDelegate {
    NSTimer *_timer;
    CGFloat _currentVolume;
    CGFloat _changeByVolume;
    CGFloat _expectedNextVolume;
    NSInteger _timeInt;
    NSInteger _ticks;
}

-(void)awakeFromNib
{
    [_goButton setAction:@selector(buttonPressed:)];
    [_goButton setTarget:self];
}

- (void)buttonPressed:(id)sender
{
    _ticks = 0;
    _timeInt = [_time.stringValue integerValue];
    _currentVolume = [ANSystemSoundWrapper systemVolume];
    _changeByVolume = _currentVolume / _timeInt;
    _expectedNextVolume = _currentVolume - _changeByVolume;
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    NSLog(@"Current Volume: %f\nChanging by %f", _currentVolume, _changeByVolume);
    [self disableTimeInput];
}

- (void)timerTick
{
    _ticks++;
    CGFloat newVolume = [ANSystemSoundWrapper systemVolume] - _changeByVolume;
    if (newVolume != _expectedNextVolume) {
        _currentVolume = [ANSystemSoundWrapper systemVolume];
        _changeByVolume = _currentVolume / (_timeInt - _ticks);
        newVolume = _currentVolume - _changeByVolume;
    }
    if (newVolume < MIN_SYSTEM_VOLUME || newVolume == MIN_SYSTEM_VOLUME) {
        newVolume = MIN_SYSTEM_VOLUME;
        [_timer invalidate];
    }
    [ANSystemSoundWrapper setSystemVolume:newVolume];
    _currentVolume = newVolume;
    NSLog(@"Current Volume: %f\n", _currentVolume);
    _expectedNextVolume = _currentVolume - _changeByVolume;
}

- (void)disableTimeInput
{
    [_time setSelectable:NO];
    [_time setEditable:NO];
    [_time setEnabled:NO];
}

@end

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
	NSUInteger _widthOfTicks;
	CGPoint _currentPoint;
}

#define MIN_TIME 1
#define MAX_TIME 1000
#define kVolumeKey @"kVolumeKey"

-(void)awakeFromNib
{
    [_goButton setAction:@selector(buttonPressed:)];
    [_goButton setTarget:self];
	
	[_stepper setAction:@selector(stepperDidChange:)];
	[_stepper setTarget:self];
	
	_time.delegate = self;
	
	_currentVolume = [ANSystemSoundWrapper systemVolume];
	[self setCurrentVolumeLabel];
	[self startVolumeWatcher];
}

#pragma mark - Button Actions

- (void)buttonPressed:(id)sender
{
	//Initialize all the variables.
    _ticks = 0;
    _timeInt = [_time.stringValue integerValue];
    _currentVolume = [ANSystemSoundWrapper systemVolume];
	
	//The change will be equal to the current Volume divided by the number of times we get to decrease (# of ticks)
    _changeByVolume = _currentVolume / (_timeInt + 1);
	
	//Expected Next Volume is always current volume minus the change. This allows us to detect if a user manually reconfigured.
    _expectedNextVolume = _currentVolume - _changeByVolume;
	
	//Timer goes off every minute
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
	
	//Disable All Time Inputs, and set relevant UI info.
    [self disableTimeInput];
	[self setCurrentVolumeLabel];
	
	[_graphView clearPoints];
	//The current point (starting point here), is at x = 0, and curent Volume percentage up the height.
	_currentPoint = CGPointMake(0.0f, roundf(_graphView.frame.size.height * _currentVolume));
	[_graphView addPoint:_currentPoint];
	
	//Width of ticks is equal to the width, divided by the number of ticks we get.
	_widthOfTicks = roundf(_graphView.frame.size.width / _timeInt);
}

#pragma mark Timer Methods

- (void)timerTick
{
    _ticks++;
	
	//Determine new volume.
    CGFloat newVolume = [ANSystemSoundWrapper systemVolume] - _changeByVolume;
	
	//If the new Volume is not the expected next volume, reconfigure
    if (newVolume != _expectedNextVolume) {
        _currentVolume = [ANSystemSoundWrapper systemVolume];
		 //new change by volume is adjusted to how many ticks are left
        _changeByVolume = _currentVolume / ((_timeInt + 1) - _ticks);
        newVolume = _currentVolume - _changeByVolume;
    }
	
	//If we're less than or equal to the MIN_SYSTEM_VOLUME, set to the MIN_SYSTEM_VOLUME, and invalidate this timer.
    if (newVolume <= MIN_SYSTEM_VOLUME) {
        newVolume = MIN_SYSTEM_VOLUME;
        [_timer invalidate];
		[self resetTimeInput];
    }
	//Set Volume
    [ANSystemSoundWrapper setSystemVolume:newVolume];
    _currentVolume = newVolume;
    _expectedNextVolume = _currentVolume - _changeByVolume;
	
	//UI Updates
	[self setCurrentVolumeLabel];
	_currentPoint = CGPointMake(_widthOfTicks * _ticks, roundf(_graphView.frame.size.height * _currentVolume));
	[_graphView addPoint:_currentPoint];
}

#pragma mark - Control Methods

- (void)disableTimeInput
{
    [_time setSelectable:NO];
    [_time setEditable:NO];
    [_time setEnabled:NO];
	
	[_stepper setEnabled:NO];
}

- (void)resetTimeInput
{
	[_time setSelectable:YES];
    [_time setEditable:YES];
    [_time setEnabled:YES];
	
	[_stepper setEnabled:YES];
}

- (void)stepperDidChange:(id)sender
{
	[_time setStringValue:[NSString stringWithFormat:@"%lu", [_stepper integerValue]]];
}

-(void)controlTextDidChange:(NSNotification *)obj
{
	NSString *timeString = [_time.stringValue stringByReplacingOccurrencesOfString:@"," withString:@""];
	NSUInteger timeValue = [timeString integerValue];
	
	if (timeValue > MAX_TIME) {
		timeValue = MAX_TIME;
	}
	if (timeValue < MIN_TIME) {
		timeValue = MIN_TIME;
	}
	
	[_time setStringValue:[NSString stringWithFormat:@"%lu", timeValue]];
	[_stepper setIntegerValue:timeValue];
	
	//Deselect Text
	NSText* fieldEditor = [self.window fieldEditor:YES forObject:_time];
	[fieldEditor setSelectedRange:NSMakeRange([[fieldEditor string] length],0)];
}

#pragma mark - Helper Methods

- (void)setCurrentVolumeLabel
{
	_currentVolumeLabel.stringValue = [NSString stringWithFormat:@"Current Volume: %@%%", [self floatToStringWithTwoDecimalPlaces:_currentVolume * 100]];
}

- (NSString *)floatToStringWithTwoDecimalPlaces:(CGFloat)value
{
	return [NSString stringWithFormat:@"%.2f", value];
}

- (void)startVolumeWatcher
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
	   ^{
		   [[NSUserDefaults standardUserDefaults] setFloat: [ANSystemSoundWrapper systemVolume] forKey: kVolumeKey];
		   [[NSUserDefaults standardUserDefaults] synchronize];
		   while (YES)
		   {
			   CGFloat volLevel = [ANSystemSoundWrapper systemVolume];
			   CGFloat oldFloat = [[NSUserDefaults standardUserDefaults] floatForKey: kVolumeKey];
			   if (volLevel != oldFloat)
			   {
				   [[NSUserDefaults standardUserDefaults] setFloat: [ANSystemSoundWrapper systemVolume] forKey: kVolumeKey];
				   [[NSUserDefaults standardUserDefaults] synchronize];
				   
				   dispatch_async(dispatch_get_main_queue(),
					  ^{
						  [self volumeDidChangeToLevel:volLevel];
					  });
			   }
		   }
	   });
}

- (void)volumeDidChangeToLevel:(CGFloat)newLevel
{
	_currentVolume = newLevel;
	[self setCurrentVolumeLabel];
}

@end

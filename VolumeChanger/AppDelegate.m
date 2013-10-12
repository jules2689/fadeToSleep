//
//  AppDelegate.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "AppDelegate.h"
#import "ANSystemSoundWrapper.h"
#import "NSView+Additions.h"
#import "BackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate {
    NSTimer *_timer;
	NSTimer *_starAdderTimer;
	
    CGFloat _currentVolume;
    CGFloat _changeByVolume;
    CGFloat _expectedNextVolume;
    NSInteger _timeInt;
    NSInteger _ticks;
	NSUInteger _widthOfTicks;
	CGPoint _currentPoint;
	
	NSMutableArray *_stars;
}

#define MIN_TIME 1
#define MAX_TIME 1000
#define kVolumeKey @"kVolumeKey"

#define LENGTH_OF_TICKS 5.0f

#define MIN_Y 225.0f
#define OFFLIMITS CGRectMake(110.0f, 340.0f, 150.0f, 96.0f)
//Cloud Right
#define OFFLIMITS2 CGRectMake(263.0f, 191.0f, 109.0f, 61.0f)
//Cloud Left
#define OFFLIMITS3 CGRectMake(0.0f, 188.0f, 113.0f, 96.0f)
//Cloud Middle
#define OFFLIMITS4 CGRectMake(106.0f, 189.0f, 170.0f, 39.0f)
#define MOONFRAME CGRectMake(0.0f, 459.0f, 80.0f, 100.0f)
#define ARC4RANDOM_MAX 0x100000000

#define nightBar [NSColor colorWithCalibratedRed:20.0f/255 green:73.0f/255 blue:99.0f/255 alpha:1.0f]
#define dayBar [NSColor colorWithCalibratedRed:66.0f/255 green:135.0f/255 blue:255.0f/255 alpha:1.0f]


-(void)awakeFromNib
{
	[super awakeFromNib];
	
	//Controls
    [_goButton setAction:@selector(buttonPressed:)];
    [_goButton setTarget:self];
	
	[_stepper setAction:@selector(stepperDidChange:)];
	[_stepper setTarget:self];
	
	[_resetButton setAction:@selector(resetAll)];
	[_resetButton setTarget:self];
	
	_time.delegate = self;
	
	[_timeLeftLabel setBackgroundColor:[NSColor clearColor]];
	_timeLeftLabel.drawsBackground = NO;
	
	//Variables
	_currentVolume = [ANSystemSoundWrapper systemVolume];
	[self setCurrentVolumeLabel];
	[self startVolumeWatcher];
	_stars = [[NSMutableArray alloc] init];
	
	//Background
	[_moon setAlphaValue:0.0f];
	[_timeLeftLabel setAlphaValue:0.0f];
}

#pragma mark - Button Actions

- (void)buttonPressed:(id)sender
{
	if ([ANSystemSoundWrapper systemVolume] != 0.0f) {
		//Initialize all the variables.
		_ticks = 0;
		_timeInt = [_time.stringValue integerValue];
		_currentVolume = [ANSystemSoundWrapper systemVolume];
		_timeLeftLabel.stringValue = [NSString stringWithFormat:@"Time Left: %lu mins", _timeInt];
		
		//The change will be equal to the current Volume divided by the number of times we get to decrease (# of ticks)
		_changeByVolume = _currentVolume / _timeInt;
		
		//Expected Next Volume is always current volume minus the change. This allows us to detect if a user manually reconfigured.
		_expectedNextVolume = _currentVolume - _changeByVolume;
		
		//Timer goes off every minute
		_timer = [NSTimer scheduledTimerWithTimeInterval:LENGTH_OF_TICKS target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
		
		//Disable All Time Inputs, and set relevant UI info.
		[self disableTimeInput];
		[self setCurrentVolumeLabel];
		
		[_graphView clearPoints];
		//The current point (starting point here), is at x = 0, and curent Volume percentage up the height.
		_currentPoint = CGPointMake(0.0f, roundf(_graphView.frame.size.height * _currentVolume));
		[_graphView addPoint:_currentPoint];
		
		//Width of ticks is equal to the width, divided by the number of ticks we get.
		_widthOfTicks = roundf(_graphView.frame.size.width / _timeInt);
		[_graphView setWidth:_widthOfTicks];
		
		[self hideControlsAndShowTime];
		[self startBackgroundAnimations];
		[self startStarAdder];
	} else {
		[self flashCurrentVolume];
	}
}

#pragma mark - Background and Image Manipulations

- (void)startBackgroundAnimations
{
	[self fadeToNight];
	[self fadeInMoon];
}

- (void)fadeToNight
{
	CGFloat timeToFade = _timeInt * LENGTH_OF_TICKS * 0.25;
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSAnimationContext currentContext] setDuration:timeToFade];
		[[_dayView animator] setAlphaValue:0.0f];
	});

}

- (void)fadeInMoon
{
	double delayInSeconds = _timeInt * 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[_moon setHidden:NO];
		[[NSAnimationContext currentContext] setDuration:_timeInt * 0.2];
		[[_moon animator] setAlphaValue:0.7f];
	});
	
}

#pragma mark - Reset Methods

- (void)resetBackground
{
	[_moon setHidden:YES];
	[_moon setAlphaValue:0.0f];
	[_moon setFrame:CGRectOffset(_moon.frame, 0.0f, -240.0f)];
	[[_dayView animator] setAlphaValue:1.0f];
}

- (void)resetAll
{
	[self resetBackground];
	[self enableTimeInput];
	[self hideTimeAndShowControls];
	for (NSImageView *star in _stars) {
		[star removeFromSuperview];
	}
	[_stars removeAllObjects];
	[_resetButton setHidden:YES];
}

- (void)hideControlsAndShowTime
{
	[_timeLeftLabel setHidden:NO];
	[_timeLeftLabel setAlphaValue:1.0f];
	[_time setAlphaValue:0.0f];
	[_stepper setAlphaValue:0.0f];
	[_goButton setAlphaValue:0.0f];
}

- (void)hideTimeAndShowControls
{
	[_timeLeftLabel setHidden:YES];
	[_timeLeftLabel setAlphaValue:0.0f];
	[_time setAlphaValue:1.0f];
	[_stepper setAlphaValue:1.0f];
	[_goButton setAlphaValue:1.0f];
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
        _changeByVolume = _currentVolume / (_timeInt - _ticks);
        newVolume = _currentVolume - _changeByVolume;
    }
	
	//If we're less than or equal to the MIN_SYSTEM_VOLUME, set to the MIN_SYSTEM_VOLUME, and invalidate this timer.
    if (newVolume <= MIN_SYSTEM_VOLUME) {
        newVolume = MIN_SYSTEM_VOLUME;
        [_timer invalidate];
		[_resetButton setHidden:NO];
    }
	
	//Set Volume
    [ANSystemSoundWrapper setSystemVolume:newVolume];
    _currentVolume = newVolume;
    _expectedNextVolume = _currentVolume - _changeByVolume;
	
	//UI Updates
	[self setCurrentVolumeLabel];
	_currentPoint = CGPointMake(_widthOfTicks * _ticks, roundf(_graphView.frame.size.height * _currentVolume));
	[_graphView addPoint:_currentPoint];
	
	_timeLeftLabel.stringValue = _timeInt - _ticks != 1 ? [NSString stringWithFormat:@"Time Left: %lu mins", _timeInt - _ticks] : @"Time Left: 1 min";
}

#pragma mark - Control Disable/Enable Methods

- (void)disableTimeInput
{
    [_time setSelectable:NO];
    [_time setEditable:NO];
    [_time setEnabled:NO];
	
	[_stepper setEnabled:NO];
}

- (void)enableTimeInput
{
	[_time setSelectable:YES];
    [_time setEditable:YES];
    [_time setEnabled:YES];
	
	[_stepper setEnabled:YES];
}

#pragma mark - NSStepper

- (void)stepperDidChange:(id)sender
{
	[_time setStringValue:[NSString stringWithFormat:@"%lu min", [_stepper integerValue]]];
	[_time setBackgroundColor:[NSColor clearColor]];
}

#pragma mark - NSTextField

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

- (void)flashCurrentVolume
{
	NSColor *color = _currentVolumeLabel.textColor;
	[[_currentVolumeLabel animator] setTextColor:[NSColor clearColor]];
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[[_currentVolumeLabel animator] setTextColor:color];
	});
	
}

- (void)setCurrentVolumeLabel
{
	_currentVolumeLabel.stringValue = [NSString stringWithFormat:@"%@%%", [self floatToStringWithTwoDecimalPlaces:_currentVolume * 100]];
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

- (void)startStarAdder
{
	double delayInSeconds = _timeInt * 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSTimeInterval starAddTime = (_timeInt * 0.75 - _timeInt * 0.2) / 25;
		_starAdderTimer = [NSTimer scheduledTimerWithTimeInterval:starAddTime target:self selector:@selector(addAStar) userInfo:nil repeats:YES];
	});
	
}

- (void)addAStar
{
	CGRect bounds = self.dayView.bounds;
	CGRect starFrame = CGRectZero;
	
	BOOL valid = NO;
	while (valid == NO) {
		CGFloat x = [self randomFloat:bounds.origin.x max:bounds.size.width - 25.0f];
		CGFloat y = [self randomFloat:MIN_Y max:bounds.size.height - 25.0f];

		starFrame = CGRectMake(x, y, 20.0f, 20.0f);
		bool thisFrameIsValid = YES;
		for (NSImageView *aStar in _stars) {
			thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(aStar.frame, starFrame) == NO;
		}
		thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(OFFLIMITS, starFrame) == NO;
		thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(OFFLIMITS2, starFrame) == NO;
		thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(OFFLIMITS3, starFrame) == NO;
		thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(OFFLIMITS4, starFrame) == NO;
		thisFrameIsValid = thisFrameIsValid && CGRectIntersectsRect(MOONFRAME, starFrame) == NO;
		valid = thisFrameIsValid;
	}
	
	NSImageView *star = [[NSImageView alloc] initWithFrame:starFrame];
	[star setImage:[NSImage imageNamed:@"star.png"]];
	[star setAlphaValue:0.0f];
	[self.view addSubview:star];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSAnimationContext currentContext] setDuration:1.8f];
		[[star animator] setAlphaValue:0.6f];
	});
	
	[_stars addObject:star];
	
	if (_stars.count >= 25) {
		[_starAdderTimer invalidate];
	}
}

- (CGFloat)randomFloat:(CGFloat)min max:(CGFloat)max
{
	arc4random_stir();
	CGFloat val = ((CGFloat)arc4random() / ARC4RANDOM_MAX) * (max - min) + min;
	return val;
}

@end

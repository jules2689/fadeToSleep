//
//  BackgroundView.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-10.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView {
	NSString *_pictureName;
}

-(void)awakeFromNib
{
	_pictureName = @"day.png";
}

- (void)setNight
{
	_pictureName = @"night.png";
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSImage *image = [NSImage imageNamed:_pictureName];
	CGFloat ratio = dirtyRect.size.width / image.size.width;
	[image setSize:CGSizeMake(dirtyRect.size.width, image.size.height * ratio)];
	[image drawAtPoint:NSZeroPoint fromRect:dirtyRect operation:NSCompositeSourceOver fraction:1];
}

@end

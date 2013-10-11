//
//  BackgroundView.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-10.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSImage *image = [NSImage imageNamed:@"clouds.png"];
	CGFloat ratio = dirtyRect.size.width / image.size.width;
	[image setSize:CGSizeMake(dirtyRect.size.width, image.size.height * ratio)];
	[image drawAtPoint:NSZeroPoint fromRect:dirtyRect operation:NSCompositeSourceOver fraction:1];
}

@end

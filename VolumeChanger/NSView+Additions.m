//
//  NSView+Additions.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-11.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "NSView+Additions.h"

@implementation NSView (Additions)

- (void)fadeInView:(NSView *)view
{
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:2.0];
	[[self animator] addSubview:view];
	[NSAnimationContext endGrouping];
}

- (void)fadeOutView:(NSView *)view
{
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:2.0];
	[[view animator] removeFromSuperview];
	[NSAnimationContext endGrouping];
}

@end

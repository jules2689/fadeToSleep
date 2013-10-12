//
//  CBLabel.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-11.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "CBLabel.h"

@implementation CBLabel

-(void)awakeFromNib
{
    [super awakeFromNib];
	self.bezeled         = NO;
	self.editable        = NO;
	self.drawsBackground = NO;
	[self setBackgroundColor:[NSColor clearColor]];
	self.drawsBackground = NO;
}

-(void)setStringValue:(NSString *)aString
{
	[super setStringValue:aString];
	[[self cell] setBackgroundColor:[NSColor clearColor]];
	[self.layer setBackgroundColor:(__bridge CGColorRef)([NSColor clearColor])];
	self.bezeled         = NO;
	self.editable        = NO;
	self.drawsBackground = NO;
	[self setBackgroundColor:[NSColor clearColor]];
	self.drawsBackground = NO;
}

@end

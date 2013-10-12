//
//  GraphView.h
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define lineColor [NSColor colorWithCalibratedRed:22.0f/255 green:62.0f/255 blue:87.0f/255 alpha:0.1f]

@interface GraphView : NSView

- (void)setWidth:(CGFloat)width;
- (void)addPoint:(CGPoint)point;
- (void)clearPoints;

@end

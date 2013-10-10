//
//  GraphView.h
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GraphView : NSView

- (void)setWidth:(CGFloat)width;
- (void)addPoint:(CGPoint)point;
- (void)clearPoints;

@end

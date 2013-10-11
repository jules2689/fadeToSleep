//
//  GraphView.m
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView {
	NSMutableArray *_points;
	CGFloat _widthOfXPoints;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	_points = [[NSMutableArray alloc] init];
}

- (void)addPoint:(CGPoint)point
{
	[_points addObject:[NSValue valueWithBytes:&point objCType:@encode(CGPoint)]];
	[self setNeedsDisplay:YES];
}

- (void)clearPoints
{
	[_points removeAllObjects];
}

- (CGPoint)currentPoint
{
	CGPoint point;
	NSValue *value = [_points lastObject];
	[value getValue:&point];
	return point;
}

- (void)setWidth:(CGFloat)width
{
	_widthOfXPoints = width;
}

-(void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	//Border
	CGPoint topLeft = CGPointMake(self.bounds.origin.x, self.bounds.size.height);
	CGPoint topRight = CGPointMake(self.bounds.size.width, self.bounds.size.height);
	CGPoint bottomLeft = CGPointMake(self.bounds.origin.x, self.bounds.origin.y);
	CGPoint bottomRight = CGPointMake(self.bounds.size.width, self.bounds.origin.y);
	
	NSBezierPath *border = [NSBezierPath bezierPath];
	[border moveToPoint:topLeft];
	[border lineToPoint:topRight];
	[border lineToPoint:bottomRight];
	[border lineToPoint:bottomLeft];
	[border lineToPoint:topLeft];
	[border setLineWidth:1.0f];
	[[NSColor gridColor] set];
	[border stroke];
	
	//Graph Lines
	NSUInteger numberOfTicks = self.frame.size.width / _widthOfXPoints + 1;
	for (NSUInteger idx = 0; idx < numberOfTicks; idx++) {
		CGPoint top = CGPointMake(roundf(_widthOfXPoints * idx), self.bounds.size.height);
		CGPoint bottom = CGPointMake(roundf(_widthOfXPoints * idx), self.bounds.origin.y);
		NSBezierPath *line = [NSBezierPath bezierPath];
		[line moveToPoint:top];
		[line lineToPoint:bottom];
		[line setLineWidth:1.0f];
		[[NSColor gridColor] set];
		[line stroke];
	}
	
	//Graph Points
	CGPoint point1;
	CGPoint point2;
	for (NSUInteger idx = 0; idx < _points.count; idx++) {
		if (idx > 0) {
			[_points[idx] getValue:&point2];
			NSBezierPath *line = [NSBezierPath bezierPath];
			[line moveToPoint:point1];
			[line lineToPoint:point2];
			[line setLineWidth:2.0f];
			[[NSColor blackColor] set];
			[line stroke];
			point1 = point2;
		} else {
			[_points[0] getValue:&point1];
		}
	}
}

@end

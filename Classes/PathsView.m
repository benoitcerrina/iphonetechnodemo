//
//  PathsView.m
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PathsView.h"
#import "PathsModel.h"

@implementation PathsView

- (id)initWithCoder:(NSCoder*)coder 
{
	if (self = [super initWithCoder:coder]) {
		
		// Set up the ability to track multiple touches.
		[self setMultipleTouchEnabled:YES];
	}
	return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch * touch in touches)
		if ([touch tapCount] >= 1)
		{
			[_delegate move: touch];
			//send the request to create a point to the controller
		}
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch * touch in touches)
		if ([touch tapCount] >= 1)
		{
			[_delegate tap: touch];
			//send the request to create a point to the controller
		}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}


- (void)drawRect:(CGRect)rect 
{
	PathsModel * lModel = [_delegate model];
	int lNbPoints = lModel.NumberOfPoints;
	CGContextRef lContext = UIGraphicsGetCurrentContext();
	CGRect lFullRect = self.frame;
	CGContextSetRGBFillColor(lContext, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(lContext, lFullRect);
	CGPoint * lPoints = lModel.Points;
	//first draw the points
	for (int lCurPointIdx = 0; lCurPointIdx < lNbPoints ;  lCurPointIdx++)
	{
		CGPoint lCurPoint = lPoints[lCurPointIdx];
		CGRect lPointRect = CGRectMake(lCurPoint.x - PRECISION/2, lCurPoint.y - PRECISION/2, PRECISION, PRECISION);
		CGContextSetRGBFillColor(lContext, 1.0, 0, 0, 1.0);
		CGContextFillRect(lContext, lPointRect);
	}
	int lNbCubicBezier = (lNbPoints - 1) / 3;
	CGContextSetRGBStrokeColor(lContext, 0, 0, 1.0, 1.0);
	CGContextMoveToPoint(lContext, lPoints[0].x, lPoints[0].y);
	//draw the cubic Beziers one by one
	for (int lCurBezier = 0; lCurBezier < lNbCubicBezier; lCurBezier++)
	{
		//draw the cubic Bezier
		int lCurStartPointIdx = 3*lCurBezier+1;
		CGContextAddCurveToPoint(lContext, lPoints[lCurStartPointIdx].x, lPoints[lCurStartPointIdx].y, lPoints[lCurStartPointIdx+1].x, lPoints[lCurStartPointIdx+1].y, lPoints[lCurStartPointIdx+2].x, lPoints[lCurStartPointIdx+2].y);
		CGContextStrokePath(lContext);
		//draw the construction lines
		CGContextMoveToPoint(lContext, lPoints[lCurStartPointIdx-1].x, lPoints[lCurStartPointIdx-1].y);
		CGContextSetRGBStrokeColor(lContext, 0, 1.0, 0, 1.0);
		CGContextAddLineToPoint(lContext, lPoints[lCurStartPointIdx].x, lPoints[lCurStartPointIdx].y);
		CGContextMoveToPoint(lContext, lPoints[lCurStartPointIdx+1].x, lPoints[lCurStartPointIdx+1].y);
		CGContextAddLineToPoint(lContext, lPoints[lCurStartPointIdx+2].x, lPoints[lCurStartPointIdx+2].y);
		CGContextStrokePath(lContext);
		CGContextMoveToPoint(lContext, lPoints[lCurStartPointIdx].x, lPoints[lCurStartPointIdx].y);
		CGContextAddLineToPoint(lContext, lPoints[lCurStartPointIdx+1].x, lPoints[lCurStartPointIdx+1].y);
		CGFloat dash1[] = {10.0,10.0};
		CGContextSetLineDash(lContext, 0, dash1, 2);
		CGContextStrokePath(lContext);
		CGContextSetLineDash(lContext, 0, 0, 0);
		
		//compute the construction points for the patial spline
		CGPoint lQ0, lQ1, lQ2, lR0, lR1, lB;
		lQ0.x = lPoints[lCurStartPointIdx-1].x*lModel.Position +lPoints[lCurStartPointIdx].x*(1-lModel.Position);
		lQ0.y = lPoints[lCurStartPointIdx-1].y*lModel.Position +lPoints[lCurStartPointIdx].y*(1-lModel.Position);
		CGContextSetRGBFillColor(lContext, 0, 0.5, 0.5, 1.0);
		CGRect lPointRect = CGRectMake(lQ0.x - PRECISION/4, lQ0.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		lQ1.x = lPoints[lCurStartPointIdx].x*lModel.Position +lPoints[lCurStartPointIdx+1].x*(1-lModel.Position);
		lQ1.y = lPoints[lCurStartPointIdx].y*lModel.Position +lPoints[lCurStartPointIdx	+1].y*(1-lModel.Position);
		 lPointRect = CGRectMake(lQ1.x - PRECISION/4, lQ1.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		lQ2.x = lPoints[lCurStartPointIdx+1].x*lModel.Position +lPoints[lCurStartPointIdx+2].x*(1-lModel.Position);
		lQ2.y = lPoints[lCurStartPointIdx+1].y*lModel.Position +lPoints[lCurStartPointIdx+2].y*(1-lModel.Position);
		 lPointRect = CGRectMake(lQ2.x - PRECISION/4, lQ2.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		CGContextSetRGBFillColor(lContext, 0.5, 0.5, 0, 1.0);
		lR0.x = lQ0.x*lModel.Position + lQ1.x*(1-lModel.Position);
		lR0.y = lQ0.y*lModel.Position + lQ1.y*(1-lModel.Position);
		 lPointRect = CGRectMake(lR0.x - PRECISION/4, lR0.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		lR1.x = lQ1.x*lModel.Position + lQ2.x*(1-lModel.Position);
		lR1.y = lQ1.y*lModel.Position + lQ2.y*(1-lModel.Position);
		 lPointRect = CGRectMake(lR1.x - PRECISION/4, lR1.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		lB.x = lR0.x*lModel.Position + lR1.x*(1-lModel.Position);
		lB.y = lR0.y*lModel.Position + lR1.y*(1-lModel.Position);

		//draw the construction points
		CGContextSetRGBFillColor(lContext, 0.5, 0.5, 0.5, 1.0);
		 lPointRect = CGRectMake(lB.x - PRECISION/4, lB.y - PRECISION/4, PRECISION/2, PRECISION/2);
		CGContextFillRect(lContext, lPointRect);
		CGContextSetRGBStrokeColor(lContext, 0.5, 0, 0.5, 1.0);
		CGContextMoveToPoint(lContext, lPoints[lCurStartPointIdx-1].x, lPoints[lCurStartPointIdx-1].y);
		CGContextAddCurveToPoint(lContext, lQ0.x, lQ0.y, lR0.x, lR0.y, lB.x, lB.y);
		CGContextSetLineWidth(lContext, PRECISION/2);
		CGContextSetLineCap(lContext, kCGLineCapRound);
		CGContextStrokePath(lContext);
		CGContextSetLineWidth(lContext, 1);
		CGContextSetRGBStrokeColor(lContext, 1.0, 0, 1.0, 1.0);
		CGContextMoveToPoint(lContext, lQ0.x, lQ0.y);
		CGContextAddLineToPoint(lContext, lQ1.x, lQ1.y);
		CGContextAddLineToPoint(lContext, lQ2.x, lQ2.y);
		CGContextStrokePath(lContext);
		CGContextMoveToPoint(lContext, lR0.x, lR0.y);
		CGContextAddLineToPoint(lContext, lR1.x, lR1.y);
		CGContextSetRGBStrokeColor(lContext, 0, 1.0, 1.0, 1.0);
		CGContextStrokePath(lContext);
		
	}
}


- (void)dealloc {
	[super dealloc];
}

-(void)setDelegate:(id<PathsViewDelegate>) iDelegate
{
	_delegate = iDelegate;	//don't retain the delegate
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self setNeedsDisplay];
}
@end

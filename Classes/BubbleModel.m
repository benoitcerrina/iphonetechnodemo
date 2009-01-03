//
//  BubblesModel.m
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BubbleModel.h"


@implementation BubbleModel
@dynamic rect;
@dynamic point;
-(CGRect)rect
{
	return _Rect;
}

-(CGPoint)point
{
	return _Point;
}

-(void)setRect: (CGRect) iRect
{
		if (!CGRectEqualToRect( iRect, _Rect)) 
		{
			_Rect = iRect;
			[self updateViews];
		}
}

-(void)setPoint: (CGPoint) iPoint
{
	if (!CGPointEqualToPoint(iPoint, _Point))
	{
		_Point = iPoint;
		[self updateViews];
	}
}

-(id) init
{
	if (self = [super init])
	{
		[self resetRect];
		}
	return self;
}
-(void) addView:(UIView*) iView
{
	if (!_Views)
	{
		_Views = [NSMutableArray arrayWithCapacity:1];
		[_Views retain];
	}
	[_Views addObject:iView];
}
-(void) updateViews
{
	if (_Views)
		for (UIView * lView in _Views)
			[lView setNeedsDisplay];
}

-(void) resetRect
{
	_Rect.size.width = 100;
	_Rect.size.height = 100;
	_Rect.origin.x = 100;
	_Rect.origin.y = 100;
	_Point.x =120;
	_Point.y = 300;
	[self updateViews];
}
@end

//
//  PathsModel.m
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PathsModel.h"


@implementation PathsModel

-(void) setPosition: (float)iPosition
{
	if (_Position != iPosition)
	{
		_Position = iPosition;
		[self updateViews];
	}
}
-(float) Position
{
	return _Position;
}
	
- (id)init 
{
	if (self = [super init]) 
	{
		// Initialization code
		_NbPoints = 0;
		[PathsModel setKeys:[NSArray arrayWithObjects: @"NumberOfPoints", nil] triggerChangeNotificationsForDependentKey:@"Points"];
	}
	return self;
}
-(void) updateViews
{
	if (_Views)
		for (UIView * lView in _Views)
			[lView setNeedsDisplay];
}

-(void) clearPath
{
	if (_NbPoints)
	{
	//	[self willChangeValueForKey:@"NumberOfPoints"];
		_NbPoints = 0;
	//	[self didChangeValueForKey:@"NumberOfPoints"];
		[self updateViews];
	}
}
 
-(CGPoint*) Points
{
	return _Points;
}
-(int) NumberOfPoints
{
	return _NbPoints;
}
-(int) MaxNumberOfPoints
{
	return 4;
}
-(void) addPoint:(CGPoint)iPoint
{
	if (_NbPoints < [self MaxNumberOfPoints])
	{
//		[self willChangeValueForKey:@"NumberOfPoints"];
		_NbPoints++;
		[self setPoint: iPoint atPosition: _NbPoints-1];
//		[self didChangeValueForKey:@"Points"];
	}
}

-(void) setPoint: (CGPoint)iPoint atPosition:(int) iPosition
{
	if (iPosition < _NbPoints && !CGPointEqualToPoint(iPoint, _Points[iPosition]))
	{
//		[self willChangeValueForKey:@"Points"];
		_Points[iPosition] = iPoint;
		[self updateViews];
//		[self didChangeValueForKey:@"Points"];
	}
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey 
{
	return  NO;
}


-(void)dealloc
{
	[_Views release];
	_Views = 0;
	[super dealloc];
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
@end

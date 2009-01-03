//
//  BubbleViewController.m
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BubbleViewController.h"


@implementation BubbleViewController

-(IBAction) clear
{
	[[self model] resetRect];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	if (!self.view)
		return;
	//use _view as somehow self.view creates a circular reference
	[(BubbleView*)self.view setDelegate: self];
	_Model = [[BubbleModel alloc] init];
	[_Model addObserver:self.view forKeyPath:@"Points" options:NSKeyValueObservingOptionNew context:_Model];
	[_Model addView:self.view];
	
	
}

//not sure which of loadView or viewDidLoad will get called
-(void)loadView
{
//when this is called the view is not loaded yet	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}



- (void)dealloc {
	[super dealloc];
	[_Model release];
	_Model = 0;
}

-(void) tap: (UITouch*) iTouch
{
}

-(void) move: (UITouch*) iTouch
{
	//find which point should have moved
	CGPoint lPrev = [iTouch previousLocationInView: self.view];

	CGPoint lPoint = _Model.point;
	CGRect lRect = _Model.rect;
	CGRect lPointRect = CGRectMake(lPoint.x - PRECISION/2, lPoint.y - PRECISION/2, PRECISION, PRECISION);
	if (CGRectContainsPoint(lPointRect, lPrev))
	{
		_Model.point = [iTouch locationInView:self.view];
	}
	lPointRect = CGRectMake(lRect.origin.x - PRECISION/2, lRect.origin.y - PRECISION/2, PRECISION, PRECISION);
	if (CGRectContainsPoint(lPointRect, lPrev))
	{
		CGRect lModelRect = _Model.rect;
		lModelRect.origin = [iTouch locationInView:self.view];
		_Model.rect = lModelRect;
	}
	lPointRect = CGRectMake(lRect.origin.x +lRect.size.width- PRECISION/2, lRect.origin.y +lRect.size.height- PRECISION/2, PRECISION, PRECISION);
	if (CGRectContainsPoint(lPointRect, lPrev))
	{
		CGRect lModelRect = _Model.rect;
		CGPoint lCurPoint = [iTouch locationInView:self.view];
		lModelRect.size.width = lCurPoint.x - lModelRect.origin.x;
		lModelRect.size.height = lCurPoint.y - lModelRect.origin.y;
		_Model.rect = lModelRect;
	}
}

-(id) model
{
	return _Model;
}


@end

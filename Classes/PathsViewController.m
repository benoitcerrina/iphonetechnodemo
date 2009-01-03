//
//  PathsAppDelegate.m
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "PathsViewController.h"
#import "PathsView.h"
#import "PathsModel.h"

@implementation PathsViewController


// Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView 
{

		
}


// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	[(PathsView*)self.view setDelegate: self];
	_Model = [[PathsModel alloc] init];
	[_Model addObserver:self.view forKeyPath:@"Points" options:NSKeyValueObservingOptionNew context:_Model];
	[_Model addView:self.view];
	[self sliderChanged];
	
	
}

/*
 Unarchives the view that is stored in the xib file.
 Initializes the main view and adds three subviews, each of which have the appearance of a piece that the user can move.
 Also creates two text labels, one that displays the touch phase, and the other that displays touch information (such as swipe, number of touches). 
 */
- (id)initWithCoder:(NSCoder*)coder 
{
	if (self = [super initWithCoder:coder]) 
	{
	}
	return self;
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

- (IBAction) clearPath
{
	[_Model clearPath];
}

-(IBAction) sliderChanged
{
	_Model.Position = _Slider.maximumValue - _Slider.value;
}

-(IBAction) playSwitchChanged
{
	if (_AnimationTimer)
	{
		[_AnimationTimer invalidate];
		[_AnimationTimer release];
		_AnimationTimer = 0;
	}
	
	if (_PlaySwitch.on)
	{
		_AnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:	@selector(nextFrame:) userInfo:0 repeats:YES];
	}
	else
	{
	}
}

-(void) nextFrame:(NSTimer*)iTimer
{
	float lPosition = _Slider.value;
	lPosition += 0.004;
	if (lPosition > _Slider.maximumValue)
		lPosition = lPosition - _Slider.maximumValue;
	[_Slider setValue: lPosition animated:YES];
	//I don't understand why programatically setting the value doesn't fire the correct slider changed action
	[self sliderChanged];
}

-(void) tap: (UITouch*) iTouch
{
	[_Model addPoint: [iTouch locationInView: self.view]];
}

-(void) move: (UITouch*) iTouch
{
	//find which point should have moved
	CGPoint lPrev = [iTouch previousLocationInView: self.view];
	CGPoint* lModelPoints = [_Model Points];
	for (int lCurPointIdx = 0; lCurPointIdx < [_Model NumberOfPoints]; lCurPointIdx++) 
	{
		CGPoint lCurPoint = lModelPoints[lCurPointIdx];
		if ((lPrev.x  > (lCurPoint.x - PRECISION)) && (lPrev.x < (lCurPoint.x + PRECISION)) && (lPrev.y > (lCurPoint.y - PRECISION)) && (lPrev.y < (lCurPoint.y + PRECISION)))
		{
			//consider that this point moved
			[_Model setPoint:[iTouch locationInView: self.view] atPosition:lCurPointIdx];
		}
	}
}

-(id) model
{
	return _Model;
}
@end

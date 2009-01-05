//
//  BubbleView.h
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathsView.h"


@interface BubbleView : PathsView 
{
	IBOutlet UISlider * _Slider;
}
-(IBAction) sliderChangedValue;
@end

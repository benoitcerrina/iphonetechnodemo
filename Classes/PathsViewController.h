//
//  PathsViewController.h
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathsModel.h"
#import "PathsView.h"

@interface PathsViewController : UIViewController <PathsViewDelegate> {
	IBOutlet UIButton *_ClearButton;
	IBOutlet UISlider * _Slider;
	IBOutlet UISwitch * _PlaySwitch;
	NSTimer * _AnimationTimer;
	PathsModel * _Model;
}
- (IBAction) clearPath;
-(IBAction) sliderChanged;
-(IBAction) playSwitchChanged;
@end


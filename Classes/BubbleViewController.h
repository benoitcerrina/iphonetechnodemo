//
//  BubbleViewController.h
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleView.h"
#import "BubbleModel.h"

@interface BubbleViewController : UIViewController <PathsViewDelegate> {
	BubbleModel * _Model;
}
-(IBAction) clear;
@end

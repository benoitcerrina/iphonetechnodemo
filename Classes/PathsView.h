//
//  PathsView.h
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathsModel.h"
#define PRECISION 12

@protocol PathsViewDelegate

-(void) tap: (UITouch*) iTouch;
-(void) move: (UITouch*) iTouch;
-(id) model;

@end

@interface PathsView : UIView {
	IBOutlet id <PathsViewDelegate> _delegate;
}
-(void)setDelegate: (id<PathsViewDelegate>) iDelegate;
@end

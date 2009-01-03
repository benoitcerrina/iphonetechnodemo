//
//  BubblesModel.h
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BubbleModel : NSObject {
	CGRect _Rect;
	CGPoint _Point;
	NSMutableArray * _Views;
}
@property (assign) CGRect rect;
@property (assign) CGPoint point;
- (id)init;
-(void) resetRect;
-(void) addView:(UIView*) iView;
-(void) updateViews;


@end

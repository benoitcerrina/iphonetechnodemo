//
//  PathsModel.h
//  Paths
//
//  Created by Benoit Cerrina on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Model for the Paths application.
 * For now the supported Path is a single Quadratic Bezier, so the Model is the array or four points.
 */
@interface PathsModel : NSObject {
	CGPoint _Points[4];
	/**
	 * Position within the Path.
	 */
	float _Position;
	Boolean _valid;
	int _NbPoints;
	NSMutableArray * _Views;
}
@property (readonly) int NumberOfPoints;
@property (readonly) CGPoint* Points;
@property float Position;
- (id)init;
-(void) clearPath;
-(CGPoint*) Points;
-(int) NumberOfPoints;
-(int) MaxNumberOfPoints;
-(void) addPoint:(CGPoint) iPoint;
-(void) setPoint:(CGPoint) iPoint atPosition: (int) iPosition;
-(void) addView:(UIView*) iView;
-(void) updateViews;

@end
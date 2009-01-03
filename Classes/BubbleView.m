//
//  BubbleView.m
//  technoDemo
//
//  Created by Benoit Cerrina on 8/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BubbleView.h"
#import "PathsView.h"
#import "BubbleModel.h"
#import "utils.h"
@interface BubbleView (privateInterface)
-(void) drawHandles:(CGContextRef) iContext;
-(void) drawBubble: (CGContextRef) iContext;
-(void) drawBubble: (CGContextRef) context withRect:(CGRect) rect withRadius: (CGFloat) radius withPoint:(CGPoint)point;
@end

@implementation BubbleView


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}

-(void) DrawGlossGradient:(CGContextRef) context color:(CGColorRef) color withRect: (CGRect) inRect  withClippingPath:(CGPathRef) iPath
{
    const float EXP_COEFFICIENT = 1.2;
    const float REFLECTION_MAX = 0.60;
    const float REFLECTION_MIN = 0.20;
	
    GlossParameters params;
	//	inRect = CGPathGetBoundingBox(iPath);
    params.expCoefficient = EXP_COEFFICIENT;
    params.expOffset = expf(-params.expCoefficient);
    params.expScale = 1.0 / (1.0 - params.expOffset);
	
	//    UIColor *source = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGColorRef source = color;
	
	memcpy(params.color, CGColorGetComponents(source), CGColorGetNumberOfComponents(source) * sizeof(CGFloat));
	
    if (CGColorGetNumberOfComponents(source) == 3)
    {
        params.color[3] = 1.0;
    }
	
    perceptualCausticColorForColor(params.color, params.caustic);
	
    float glossScale = perceptualGlossFractionForColor(params.color);
	
    params.initialWhite = glossScale * REFLECTION_MAX;
    params.finalWhite = glossScale * REFLECTION_MIN;
	
    static const float input_value_range[2] = {0, 1};
    static const float output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    CGFunctionCallbacks callbacks = {0, glossInterpolation, NULL};
	
    CGFunctionRef gradientFunction = CGFunctionCreate(
													  (void *)&params,
													  1, // number of input values to the callback
													  input_value_range,
													  4, // number of components (r, g, b, a)
													  output_value_ranges,
													  &callbacks);
	
    CGPoint startPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMaxY(inRect));
	CGPoint endPoint = CGPointMake(CGRectGetMinX(inRect), CGRectGetMinY(inRect)); 
  	
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGShadingRef shading = CGShadingCreateAxial(colorspace, endPoint,
												startPoint, gradientFunction, TRUE, TRUE);
	
    CGContextSaveGState(context);
	CGContextAddPath(context, iPath);
	CGContextClip(context);
	
	//    CGContextClipToRect(context, inRect);
    CGContextDrawShading(context, shading);
    CGContextRestoreGState(context);
	
    CGShadingRelease(shading);
    CGColorSpaceRelease(colorspace);
    CGFunctionRelease(gradientFunction);
}


-(void) drawBubble: (CGContextRef) context withRect:(CGRect) rrect withRadius: (CGFloat) radius withPoint:(CGPoint) point
{
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect), midPoint1x=(point.x+midx)/2, midPoint2x =(point.x + minx)/2;
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect), midPointy=(point.y+maxy)/2;
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 10              5
	// maxy    9       7       6
	// midpoints  8.5 7.5
	// point        8
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	CGMutablePathRef lPath = CGPathCreateMutable();
	// Start at 1
	CGPathMoveToPoint(lPath, nil,  minx, midy);
	// Add an arc through 2 to 3
	CGPathAddArcToPoint(lPath, nil, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGPathAddArcToPoint(lPath, nil, maxx, miny, maxx, midy, radius);
	float lTmpRadius = radius < maxx-midPoint1x ? radius : maxx-midPoint1x;
	
	// Add an arc through 6 to 7
	CGPathAddArcToPoint(lPath, nil, maxx, maxy, midx, maxy, lTmpRadius);
	//Add an arc through midpoint1 to 8
	CGPathAddCurveToPoint(lPath, nil, midPoint1x, maxy, midPoint1x, midPointy, point.x, point.y);
	CGPathAddCurveToPoint(lPath, nil, midPoint2x, midPointy, midPoint1x, maxy, midPoint2x, maxy);
	
//	CGContextAddArcToPoint(context, midPoint1x, midPointy, point.x, point.y, radius);
	//Add an arc through midpoint2 to between 7 and 9
//	CGContextAddArcToPoint(context, midPoint2x, midPointy, (minx+midx)/2, maxy, radius);
	// Add an arc through 9 to 10
	lTmpRadius = radius < midPoint2x-minx ? radius : midPoint2x-minx;
	CGPathAddArcToPoint(lPath, nil, minx, maxy, minx, midy, lTmpRadius);
	// Close the path
	CGPathCloseSubpath(lPath);
	//now shade it
	[self DrawGlossGradient:context color:[UIColor greenColor].CGColor withRect:rrect withClippingPath:lPath];
	CGContextAddPath(context, lPath);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathStroke);
	
}

-(void) drawBubble: (CGContextRef) iContext
{
	BubbleModel * lModel = [_delegate model];
	if (!lModel)
		return;
	CGRect lRect = lModel.rect;
	//draw the rect
	CGContextSetRGBStrokeColor(iContext, 0, 0, 1.0, 1.0);
	CGContextSetLineWidth(iContext, 3.0);
	//CGContextStrokeRect(iContext, lRect);
	
	[self drawBubble:iContext withRect:lRect withRadius: (lRect.size.width < lRect.size.height?lRect.size.width:lRect.size.height)/5 withPoint: lModel.point];
	
}

-(void) drawHandles:(CGContextRef) iContext
{
	BubbleModel * lModel = [_delegate model];
	if (!lModel)
		return;
	
	CGPoint lPoint = lModel.point;
	CGRect lRect = lModel.rect;
	
	//draw the point handle
	CGRect lPointRect = CGRectMake(lPoint.x - PRECISION/2, lPoint.y - PRECISION/2, PRECISION, PRECISION);
	CGContextSetRGBFillColor(iContext, 1.0, 0, 0, 1.0);
	
	CGContextFillRect(iContext, lPointRect);
	
	//draw the rect handles
	CGContextSetRGBFillColor(iContext, 0, 1.0, 0, 1.0);
	lPointRect = CGRectMake(lRect.origin.x - PRECISION/2, lRect.origin.y - PRECISION/2, PRECISION, PRECISION);
	CGContextFillRect(iContext, lPointRect);
	lPointRect = CGRectMake(lRect.origin.x +lRect.size.width- PRECISION/2, lRect.origin.y +lRect.size.height- PRECISION/2, PRECISION, PRECISION);
	CGContextFillRect(iContext, lPointRect);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef lContext = UIGraphicsGetCurrentContext();
	CGRect lFullRect = self.frame;
	CGContextSetRGBFillColor(lContext, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(lContext, lFullRect);
	
	[self drawHandles: lContext];
	
	[self drawBubble: lContext];
	
	
}


- (void)dealloc {
	[super dealloc];
}


@end
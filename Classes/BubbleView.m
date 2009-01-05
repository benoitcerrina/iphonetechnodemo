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
-(void) DrawBccGradient:(CGContextRef) context color:(CGColorRef) color withRect: (CGRect) inRect withBubbleRadius:(CGFloat) iRadius withClippingPath:(CGPathRef) iPath;
-(void)	drawHighlight: (CGContextRef) iContext withBubbleRect: (CGRect) iRect withBubbleRadius: (CGFloat) iRadius;
@end

@implementation BubbleView




-(IBAction)sliderChangedValue
{
	[self setNeedsDisplay];	
	
}
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) 
	{
		// Initialization code
	}
	return self;
}

-(void) DrawBccGradient:(CGContextRef) iContext color:(CGColorRef) iColor withRect: (CGRect) iInRect withBubbleRadius:(CGFloat)iRadius withClippingPath:(CGPathRef) iPath
{

	
    GradParameters lParams;
	//	inRect = CGPathGetBoundingBox(iPath);
 
	CGColorRef lSource = iColor;
	
	memcpy(lParams.color, CGColorGetComponents(lSource), CGColorGetNumberOfComponents(lSource) * sizeof(CGFloat));
	
    if (CGColorGetNumberOfComponents(lSource) == 3)
    {
        lParams.color[3] = 1.0;
    }
	
    perceptualCausticColorForColor(lParams.color, lParams.bottomcolor);
	perceptualTopColorForColor(lParams.color, lParams.topcolor);
	
	lParams.fractionNoGrad = (iInRect.size.height - 2*iRadius)/iInRect.size.height;
	
	
	//now shade it
	CGGradientRef lGradient;
	CGColorSpaceRef lColorSpace;
	size_t lNumLocations = 4;
	CGFloat lLocations[4] = { 0.0, iRadius/iInRect.size.height, (iInRect.size.height - iRadius)/ iInRect.size.height, 1.0 };		//0.9 so that it stops at the end of the bubble's radius
	CGFloat lComponents[16] = { lParams.topcolor[0], lParams.topcolor[1], lParams.topcolor[2], lParams.topcolor[3],  // Start color
								lParams.color[0], lParams.color[1], lParams.color[2], lParams.color[3],  // mid color
								lParams.color[0], lParams.color[1], lParams.color[2], lParams.color[3],  // mid color
								lParams.bottomcolor[0], lParams.bottomcolor[1],lParams.bottomcolor[2], lParams.bottomcolor[3]};	//bottom color

	
	lColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	lGradient = CGGradientCreateWithColorComponents (lColorSpace, lComponents,
													 lLocations, lNumLocations);
	CGPoint lStartPoint, lEndPoint;
	lStartPoint.x = iInRect.origin.x;
	lStartPoint.y = iInRect.origin.y;
	lEndPoint.x = iInRect.origin.x;
	lEndPoint.y = iInRect.origin.y + iInRect.size.height;
	//clip by the highlight rounded rect defined previously
	CGContextAddPath(iContext, iPath);
	CGContextClip(iContext);
	CGContextDrawLinearGradient (iContext, lGradient, lStartPoint, lEndPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(lGradient);
	CGColorSpaceRelease(lColorSpace);
    
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
	//params.caustic[2] = 1.0; params.caustic[1] = 0.0; params.caustic[0] = 0.0;
    float glossScale = perceptualGlossFractionForColor(params.color);
	
    params.initialWhite = glossScale * REFLECTION_MAX;
    params.finalWhite = glossScale * REFLECTION_MIN;
	params.percentNoGrad = _Slider.value;
	
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
												startPoint, gradientFunction, FALSE, 
												FALSE);
	
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


-(void)	drawHighlight: (CGContextRef) iContext withBubleRect: (CGRect) iRect withBubbleRadius: (CGFloat) iRadius
{
	CGContextSaveGState(iContext);
	//first define the enclosing rect. 
	// the height will be 10% more than the radius of the bubble corners.  
	// the width will be the width of the bubble rectangle - 0.6 * radius
	
	CGRect lGlossRect = CGRectMake(iRect.origin.x + 0.3 * iRadius , iRect.origin.y + iRadius/10.0, iRect.size.width -  0.6 *iRadius, iRadius *0.8);
	CGFloat lRadius = lGlossRect.size.height/2;
	//first draw the bubble	
	
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(lGlossRect), midx = CGRectGetMidX(lGlossRect), maxx = CGRectGetMaxX(lGlossRect);
	CGFloat miny = CGRectGetMinY(lGlossRect), midy = CGRectGetMidY(lGlossRect), maxy = CGRectGetMaxY(lGlossRect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	CGMutablePathRef lPath = CGPathCreateMutable();
	// Start at 1
	CGPathMoveToPoint(lPath, nil,  minx, midy);
	// Add an arc through 2 to 3
	CGPathAddArcToPoint(lPath, nil, minx, miny, midx, miny, lRadius);
	// Add an arc through 4 to 5
	CGPathAddArcToPoint(lPath, nil, maxx, miny, maxx, midy, lRadius);
	// Add an arc through 6 to 7
	CGPathAddArcToPoint(lPath, nil, maxx, maxy, midx, maxy, lRadius);
	//Add an arc through midpoint2 to between 7 and 8
	CGPathAddArcToPoint(lPath, nil, minx, maxy, minx, midy, lRadius);
	// Close the path
	CGPathCloseSubpath(lPath);
	//now shade it
	CGGradientRef lGradient;
	CGColorSpaceRef lColorSpace;
	size_t lNumLocations = 2;
	CGFloat lLocations[2] = { 0.0, 0.9 };		//0.9 so that it stops at the end of the bubble's radius
	CGFloat lComponents[8] = { 1.0, 1.0, 1.0, 1.0,  // Start color
	1.0, 1.0, 1.0, 0.0 }; // End color
	
	lColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	lGradient = CGGradientCreateWithColorComponents (lColorSpace, lComponents,
													  lLocations, lNumLocations);
	CGPoint lStartPoint, lEndPoint;
	lStartPoint.x = minx;
	lStartPoint.y = miny;
	lEndPoint.x = minx;
	lEndPoint.y = maxy;
	//clip by the highlight rounded rect defined previously
	CGContextAddPath(iContext, lPath);
	CGContextClip(iContext);
	lGlossRect.size.height *= 0.9;
	CGContextClipToRect(iContext, lGlossRect);
	CGContextDrawLinearGradient (iContext, lGradient, lStartPoint, lEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(lGradient);
	CGContextRestoreGState(iContext);
	
}


-(void) drawBubble: (CGContextRef) iContext withRect:(CGRect) iRect withRadius: (CGFloat) iRadius withPoint:(CGPoint) iPoint
{
	
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(iRect), midx = CGRectGetMidX(iRect), maxx = CGRectGetMaxX(iRect), midPoint1x=(iPoint.x+midx)/2, midPoint2x =(iPoint.x + minx)/2;
	CGFloat miny = CGRectGetMinY(iRect), midy = CGRectGetMidY(iRect), maxy = CGRectGetMaxY(iRect), midPointy=(iPoint.y+maxy)/2;
	
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
	CGPathAddArcToPoint(lPath, nil, minx, miny, midx, miny, iRadius);
	// Add an arc through 4 to 5
	CGPathAddArcToPoint(lPath, nil, maxx, miny, maxx, midy, iRadius);
	float lTmpRadius = iRadius < maxx-midPoint1x ? iRadius : maxx-midPoint1x;
	
	// Add an arc through 6 to 7
	CGPathAddArcToPoint(lPath, nil, maxx, maxy, midx, maxy, lTmpRadius);
	//Add an arc through midpoint1 to 8
	CGPathAddCurveToPoint(lPath, nil, midPoint1x, maxy, midPoint1x, midPointy, iPoint.x, iPoint.y);
	CGPathAddCurveToPoint(lPath, nil, midPoint2x, midPointy, midPoint1x, maxy, midPoint2x, maxy);
	
//	CGContextAddArcToPoint(context, midPoint1x, midPointy, point.x, point.y, radius);
	//Add an arc through midpoint2 to between 7 and 9
//	CGContextAddArcToPoint(context, midPoint2x, midPointy, (minx+midx)/2, maxy, radius);
	// Add an arc through 9 to 10
	lTmpRadius = iRadius < midPoint2x-minx ? iRadius : midPoint2x-minx;
	CGPathAddArcToPoint(lPath, nil, minx, maxy, minx, midy, lTmpRadius);
	// Close the path
	CGPathCloseSubpath(lPath);
	//now draw the shadow
	CGContextAddPath(iContext, lPath);
	CGContextSetShadow(iContext, CGSizeMake(0.0, -3.0), 1.0);
	// Fill & stroke the path
	CGContextDrawPath(iContext, kCGPathFill);  //this will be overwritten by the gradient but the shadow won't be
	UIColor * lMainColor = [UIColor colorWithRed:146.0/255.0 green:216.0/255.0 blue:65.0/255.0 alpha:1.0];
	//now shade it
	[self DrawBccGradient:iContext color:lMainColor.CGColor withRect:iRect withBubbleRadius: iRadius withClippingPath:lPath];
	//now draw the glossy highlight 	
	[self drawHighlight: iContext withBubleRect: iRect withBubbleRadius: iRadius];
	

}

-(void) drawBubble: (CGContextRef) iContext
{
	BubbleModel * lModel = [_delegate model];
	if (!lModel)
		return;
	CGRect lRect = lModel.rect;
	//draw the rect
	CGContextSetRGBStrokeColor(iContext, 0, 0, 1.0, 1.0);
	CGContextSetLineWidth(iContext, 1.0);
	//CGContextStrokeRect(iContext, lRect);
	
	[self drawBubble:iContext withRect:lRect withRadius: 10 withPoint: lModel.point];
	
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
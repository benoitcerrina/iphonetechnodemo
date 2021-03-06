/*
 *  utils.c
 *  technoDemo
 *  note that comments are from where I found the sample
 *  Created by Benoit Cerrina on 12/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "utils.h"


static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v );
void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );


void gradientFunc(void *info, const float * input, float * output)
{
	//first translate the parameters
    GradParameters *lParams = (GradParameters *)info;
	
    float lProgress = *input;
	NSCAssert(lParams->fractionNoGrad <= 1, @"Invalid parameter");
	//there are 3 subpart of the gradient
	float lFirstLimit = (1-lParams->fractionNoGrad)/2;
	float lSecondLimit = (1+lParams->fractionNoGrad)/2;
	if (lProgress < lFirstLimit)
	{
		lProgress /= lFirstLimit;
		//for now no gradient just send the color back
		for (int iIndex = 0; iIndex < 4; iIndex++) 
			output[iIndex] = lParams->color[iIndex] * lProgress + lParams->topcolor[iIndex] * (1-lProgress);
	}
	else if (lProgress < lSecondLimit)
	{
		memcpy(output, lParams->color, 4 * sizeof(CGFloat));
	}
	else
	{
		lProgress = (lProgress - lSecondLimit) / lFirstLimit;
		for (int iIndex = 0; iIndex < 4; iIndex++) 
			output[iIndex] = lParams->bottomcolor[iIndex] * lProgress + lParams->color[iIndex] * (1-lProgress);
	}

}



 void glossInterpolation(void *info, const float *input,float *output)
{
    GlossParameters *params = (GlossParameters *)info;
	
    float progress = *input;
    float lPercent = (1- params->percentNoGrad)/2;
	if (progress < lPercent)
    {
        progress = progress / lPercent;
		
        progress = 1.0 - params->expScale * (expf(progress * -params->expCoefficient) - params->expOffset);
		
        float currentWhite = progress * (params->finalWhite - params->initialWhite) + params->initialWhite;
		
        output[0] = params->color[0] * (1.0 - currentWhite) + currentWhite;
        output[1] = params->color[1] * (1.0 - currentWhite) + currentWhite;
        output[2] = params->color[2] * (1.0 - currentWhite) + currentWhite;
        output[3] = params->color[3] * (1.0 - currentWhite) + currentWhite;
    }
    else
		if (progress < 1-lPercent)
		{
			output[0] = params->color[0];
			output[1] = params->color[1];
			output[2] = params->color[2];
			output[3] = params->color[3];
		}
	else
    {
        progress = (progress - (1 - lPercent)) / lPercent;
		
//        progress = params->expScale * (expf((1.0 - progress) * - params->expCoefficient) - params->expOffset);
		
        output[0] = params->color[0] * (1.0 - progress) + params->caustic[0] * progress;
        output[1] = params->color[1] * (1.0 - progress) + params->caustic[1] * progress;
        output[2] = params->color[2] * (1.0 - progress) + params->caustic[2] * progress;
        output[3] = params->color[3] * (1.0 - progress) + params->caustic[3] * progress;
    }
}

void perceptualTopColorForColor(float *inputComponents, float *outputComponents)
{
    float hue, saturation, brightness, alpha;
	
	RGBtoHSV(inputComponents[0], inputComponents[1], inputComponents[2], &hue, &saturation, &brightness);
	
	
	brightness /= 2;
	
    if (saturation < 1e-3)
    {
    }
	else
		hue +=0.1;
	HSVtoRGB(&outputComponents[0], &outputComponents[1], &outputComponents[2], hue, saturation, brightness);
	outputComponents[3] = inputComponents[3];
}
 void perceptualCausticColorForColor(float *inputComponents, float *outputComponents)
{
    const float CAUSTIC_FRACTION = 0.60;
    const float COSINE_ANGLE_SCALE = 1.4;
    const float MIN_RED_THRESHOLD = 0.95;
    const float MAX_BLUE_THRESHOLD = 0.7;
    const float GRAYSCALE_CAUSTIC_SATURATION = 0.2;
	
    float hue, saturation, brightness, alpha;
	
	RGBtoHSV(inputComponents[0], inputComponents[1], inputComponents[2], &hue, &saturation, &brightness);
	
	
	float targetHue, targetSaturation, targetBrightness;
	
	
	CGColorRef theYellow = [[UIColor yellowColor] CGColor];
	const CGFloat *theYellowComponents = CGColorGetComponents(theYellow);
	RGBtoHSV(theYellowComponents[0], theYellowComponents[1], theYellowComponents[2], &targetHue, &targetSaturation, &targetBrightness);
	
	
    if (saturation < 1e-3)
    {
        hue = targetHue;
        saturation = GRAYSCALE_CAUSTIC_SATURATION;
    }
	
    if (hue > MIN_RED_THRESHOLD)
    {
        hue -= 1.0;
    }
    else if (hue > MAX_BLUE_THRESHOLD)
    {
		CGColorRef theMagenta = [[UIColor magentaColor] CGColor];
		const CGFloat *theMagentaComponents = CGColorGetComponents(theMagenta);
		RGBtoHSV(theMagentaComponents[0], theMagentaComponents[1], theMagentaComponents[2], &targetHue, &targetSaturation, &targetBrightness);
		
    }
	
    float scaledCaustic = CAUSTIC_FRACTION * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * M_PI * (hue - targetHue)));
	
	hue = hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic;
	brightness = brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic;
	
	HSVtoRGB(&outputComponents[0], &outputComponents[1], &outputComponents[2], hue, saturation, brightness);
	outputComponents[3] = inputComponents[3];
}

 float perceptualGlossFractionForColor(float *inputComponents)
{
    const float REFLECTION_SCALE_NUMBER = 0.2;
    const float NTSC_RED_FRACTION = 0.299;
    const float NTSC_GREEN_FRACTION = 0.587;
    const float NTSC_BLUE_FRACTION = 0.114;
	
    float glossScale =
	NTSC_RED_FRACTION * inputComponents[0] +
	NTSC_GREEN_FRACTION * inputComponents[1] +
	NTSC_BLUE_FRACTION * inputComponents[2];
    glossScale = pow(glossScale, REFLECTION_SCALE_NUMBER);
    return glossScale;
}


void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
	float min, max, delta;
	min = MIN( r, MIN(g, b) );
	max = MAX( r, MAX(g, b) );
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
	*h/=360;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	
    h *= 360; 
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

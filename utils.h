/*
 *  utils.h
 *  technoDemo
 *
 *  Created by Benoit Cerrina on 12/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

/**
 * draw an aqua style gradient in a path using a specified base color.
 * the gradient will be defined for the rect passed in and extended to the path.
 */
void DrawGlossGradient(CGContextRef context, CGColorRef color, CGRect inRect, CGPathRef iPath);
typedef struct
	{
		float color[4];
		float caustic[4];
		float expCoefficient;
		float expScale;
		float expOffset;
		float initialWhite;
		float finalWhite;
		float percentNoGrad;
	} GlossParameters;
typedef struct
	{
		float topcolor[4];
		float color[4];
		float bottomcolor[4];
		float fractionNoGrad;
	} GradParameters;
//function based on the cocoadev article
 void glossInterpolation(void *info, const float *input, float *output);
//benwulf gradient
void gradientFunc(void *info, const float * input, float * output);
 void perceptualCausticColorForColor(float *inputComponents, float *outputComponents);
void perceptualTopColorForColor(float *inputComponents, float *outputComponents);
 float perceptualGlossFractionForColor(float *inputComponents);

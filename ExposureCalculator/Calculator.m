//
//  Calculator.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "Calculator.h"
#include <math.h>

@implementation Calculator

+ (int)lvForAperture:(double)fNumber shutter:(double)seconds sensitivity:(int)iso
{
	double ev = log2(fNumber * fNumber / seconds);
	
	// Adjust for ISO
	double e = log2((double)iso / 100.0);
	double result = 3 * (ev - e);
	// Round to the nearest third stop
	return (int)(result + (result < 0 ? -0.5 : 0.5));
}

@end

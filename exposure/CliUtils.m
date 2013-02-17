//
//  CliUtils.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "CliUtils.h"
#include <string.h>

@implementation CliUtils

+ (NSNumber *)shutterFromString:(const char *)s
{
	if (strncmp(s, "1/", 2) == 0) {
		s += 2;
		int denom;
		
		if (sscanf(s, "%d", &denom) == 1) {
			return [NSNumber numberWithDouble:1.0/(double)denom];
		} else {
			return nil;
		}
	} else {
		int seconds;
		
		if (sscanf(s, "%d", &seconds) == 1) {
			return [NSNumber numberWithDouble:(double)seconds];
		} else {
			return nil;
		}
	}
}

+ (NSNumber *)apertureFromString:(const char *)s
{
	if (strncmp(s, "f/", 2) == 0) {
		s += 2;
	}
	
	double fnum;
	
	if (sscanf(s, "%lf", &fnum) == 1) {
		return [NSNumber numberWithDouble:fnum];
	} else {
		return nil;
	}
}

+ (NSNumber *)intFromString:(const char *)s
{
	int n;
	
	if (sscanf(s, "%d", &n) == 1) {
		return [NSNumber numberWithInt:n];
	} else {
		return nil;
	}
}



@end

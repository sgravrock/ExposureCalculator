//
//  MinMaxPair.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "MinMaxPair.h"

@implementation MinMaxPair

- (id)initWithMin:(int)min max:(int)max
{
	self = [super init];
	
	if (self) {
		_min = min;
		_max = max;
	}
	
	return self;
}

- (void)setMin:(int)value
{
	_min = value;
	
	if (self.max < value) {
		self.max = value;
	}
}

- (void)setMax:(int)value
{
	_max = value;
	
	if (self.min > value) {
		self.min = value;
	}
}

@end

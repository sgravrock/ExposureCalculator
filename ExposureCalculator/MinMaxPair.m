//
//  MinMaxPair.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "MinMaxPair.h"

@interface MinMaxPair() {
	int limit;
}
@end

@implementation MinMaxPair

- (id)initWithLimit:(int)theLimit
{
	self = [super init];
	
	if (self) {
		_min = 0;
		_max = limit = theLimit;
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

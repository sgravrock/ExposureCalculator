//
//  Calculator.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "Calculator.h"
#import "SupportedSettings.h"
#include <math.h>

@implementation Calculator

+ (int)thirdsLvForAperture:(double)fNumber shutter:(double)seconds sensitivity:(int)iso
{
	double ev = log2(fNumber * fNumber / seconds);
	
	// Adjust for ISO
	double e = log2((double)iso / 100.0);
	double result = 3 * (ev - e);
	// Round to the nearest third stop
	return (int)(result + (result < 0 ? -0.5 : 0.5));
}

- (id)initWithSettings:(SupportedSettings *)settings
{
	self = [super init];
	
	if (self) {
		self.supportedSettings = settings;
		self.thirdsLv = 0;
	}
	
	return self;
}

- (NSArray *)validSettings
{
	NSMutableArray *settings = [NSMutableArray array];

	for (NSNumber *aperture in self.supportedSettings.apertures) {
		for (NSNumber *shutter in self.supportedSettings.shutterSpeeds) {
			for (NSNumber *iso in self.supportedSettings.sensitivities) {
				if (self.thirdsLv == [Calculator thirdsLvForAperture:[aperture doubleValue]
															 shutter:[shutter doubleValue]
														 sensitivity:[iso intValue]]) {
					[settings addObject:@{@"aperture": aperture,
					 @"shutterSpeed": shutter, @"sensitivity": iso}];
				}
			}
		}
	}
	
	return settings;
}
@end

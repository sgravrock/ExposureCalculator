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

@interface Calculator()
@property (nonatomic, strong) SupportedSettings *supportedSettings;
@end

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

- (id)initWithSettings:(SupportedSettings *)settings
{
	self = [super init];
	
	if (self) {
		self.supportedSettings = settings;
		self.lockedAperture = self.lockedSensitivity = self.lockedShutterSpeed = nil;
		self.lv = 0;
	}
	
	return self;
}

- (NSArray *)validSettings
{
	NSMutableArray *settings = [NSMutableArray array];
	NSArray *apertures = self.lockedAperture ? [NSArray arrayWithObject:self.lockedAperture]
		: self.supportedSettings.apertures;
	NSArray *shutters = self.lockedShutterSpeed ? [NSArray arrayWithObject:self.lockedShutterSpeed]
		: self.supportedSettings.shutterSpeeds;
	NSArray *isos = self.lockedSensitivity ? [NSArray arrayWithObject:self.lockedSensitivity]
		: self.supportedSettings.sensitivities;

	for (NSNumber *aperture in apertures) {
		for (NSNumber *shutter in shutters) {
			for (NSNumber *iso in isos) {
				if (self.lv == [Calculator lvForAperture:[aperture doubleValue]
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

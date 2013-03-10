//
//  SupportedSettings.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "SupportedSettings.h"


static SupportedSettings *_defaultSettings;

@interface SupportedSettings()
@property (nonatomic, strong) NSArray *apertures;
@property (nonatomic, strong) NSArray *shutterSpeeds;
@property (nonatomic, strong) NSArray *sensitivities;
@end

@implementation SupportedSettings


+ (SupportedSettings *)defaultSettings
{
	if (!_defaultSettings) {
		NSArray *apertures = @[@1.4, @1.6, @1.8, @2.0, @2.2, @2.5,
			@2.8, @3.2, @3.5, @4.0, @4.5, @5.0, @5.6, @6.3, @7.1, @8.0,
			@9.0, @10.0, @11.0, @13.0, @14.0, @16.0, @18.0, @20.0, @22.0];
		NSArray *sensitivities = @[@50, @64, @100, @125, @160, @200, @250, @320, @400, @500, @640,
			@800, @1000, @1250, @1600, @2000, @2500, @3200, @4000, @5000, @6400];
		
		NSMutableArray *speeds = [NSMutableArray arrayWithCapacity:63];
		
		// For shutter speeds longer than 30 seconds, calculate third-stop increments using the
		// cube root method. The accumulated error from a less accurate method would be
		// considerable. The user's camera settings most likely don't extend into this range
		// (bulb will be used instead), so we don't need to worry about matching the approximations
		// that would be displayed on the camera.
		double cbrt2 = cbrt(2);

		for (double i = 32 * 60; i > 30; i /= cbrt2) {
			[speeds addObject:[NSNumber numberWithDouble:i]];
		}
		
		// For speeds faster than 30 seconds, hardcode the approximations that are displayed on
		// a typical camera. The error from this is small enough that rounding Lv calculations to
		// the nearest third stop will take care of it.
		NSArray *overlappingRange = @[@30, @25, @20, @15, @13, @10, @8, @6, @5, @4, @3, @2.5, @2,
		@1.6, @1.3, @1];
		[speeds addObjectsFromArray:overlappingRange];
		
		for (int i = overlappingRange.count - 2; i >= 0; i--) {
			[speeds addObject:[NSNumber numberWithDouble:1.0/[overlappingRange[i] doubleValue]]];
		}
		
		NSArray *higher = @[@40, @50, @60, @80, @100, @125, @160, @200, @250, @320, @400,
		@500, @640, @800];
		
		for (NSNumber *n in higher) {
			[speeds addObject:[NSNumber numberWithDouble:1.0/[n doubleValue]]];
		}

		_defaultSettings = [[SupportedSettings alloc] initWithApertures:apertures
														  shutterSpeeds:speeds
														  sensitivities:sensitivities];
	}
	
	return _defaultSettings;
}


- (id)initWithApertures:(NSArray *)apertures
		  shutterSpeeds:(NSArray *)shutterSpeeds
		  sensitivities:(NSArray *)sensitivities
{
	self = [super init];
	
	if (self) {
		self.apertures = apertures;
		self.shutterSpeeds = shutterSpeeds;
		self.sensitivities = sensitivities;
	}
	
	return self;
}


@end

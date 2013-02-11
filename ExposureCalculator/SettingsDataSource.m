//
//  SettingsDataSource.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "SettingsDataSource.h"

@interface SettingsDataSource()
@property (nonatomic, strong) NSArray *apertures;
@property (nonatomic, strong) NSArray *shutterSpeeds;
@property (nonatomic, strong) NSArray *isos;
@end

@implementation SettingsDataSource

- (id)init
{
	self = [super init];
	
	if (self) {
		self.apertures = @[@1.4, @1.6, @1.8, @2.0, @2.2, @2.5,
						  @2.8, @3.2, @3.5, @4.0, @4.5, @5.0, @5.6, @6.3, @7.1, @8.0,
						  @9.0, @10.0, @11.0, @13.0, @14.0, @16.0, @18.0, @20.0, @22.0];
		self.isos = @[@50, @64, @100, @125, @160, @200, @250, @320, @400, @500, @640,
						@800, @1000, @1250, @1600, @2000, @2500, @3200, @4000, @5000, @6400];
		
		// Calculate full stop increments for shutter speeds slower than 30 seconds, to keep the
		// total number of possible settings sane. Above 30 seconds, switch to third stops
		// and hardcode because the third stop values used by cameras are slightly different
		// than what the math expects.
		NSMutableArray *speeds = [NSMutableArray arrayWithCapacity:51];
		
		for (int i = 32 * 60; i >= 30; i /= 2) {
			[speeds addObject:[NSNumber numberWithDouble:(double)i]];
		}
		
		NSArray *overlappingRange = @[@25.0, @20.0, @15.0, @13.0, @10.0, @8.0, @6.0, @5.0, @4.0,
										@3.0, @2.5, @2.0, @1.6, @1.3, @1];
		[speeds addObjectsFromArray:overlappingRange];
		
		for (int i = overlappingRange.count - 2; i >= 0; i--) {
			[speeds addObject:[NSNumber numberWithDouble:1.0/[overlappingRange[i] doubleValue]]];
		}
		
		NSArray *higher = @[@30, @40, @50, @60, @80, @100, @125, @160, @200, @250, @320, @400,
				@500, @640, @800];
		
		for (NSNumber *n in higher) {
			[speeds addObject:[NSNumber numberWithDouble:1.0/[n doubleValue]]];
		}

		self.shutterSpeeds = speeds;
	}
	
	return self;
}

#pragma mark - UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return self.apertures.count;
		case 1:
			return self.shutterSpeeds.count;
		case 2:
			return self.isos.count;
		default:
			@throw [NSException exceptionWithName:@"Invalid argument"
										   reason:@"Component out of range"
										 userInfo:nil];
	}
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return [NSString stringWithFormat:@"f/%@", self.apertures[row]];
		case 1:
			return [self formatShutterSpeed:[self.shutterSpeeds[row] doubleValue]];
		case 2:
			return [self.isos[row] stringValue];
		default:
			@throw [NSException exceptionWithName:@"Invalid argument"
										   reason:@"Component out of range"
										 userInfo:nil];
	}
}

#pragma mark -

- (NSString *)formatShutterSpeed:(double)speed
{
	if (speed == 60) {
		return @"1m";
	} else if (speed > 60) {
		return [NSString stringWithFormat:@"%dm", (int)speed / 60];
	} else if (speed >= 1) {
		return [NSString stringWithFormat:@"%g", speed];
	} else {
		return [NSString stringWithFormat:@"1/%g", 1.0/speed]; // display e.g. 1.0/500.0 as "1/500"
 	}
}


@end

//
//  Setting.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/24/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "Setting.h"

@interface Setting()
@property (nonatomic, assign) int component;
@property (nonatomic, strong) NSNumber *value;
@end

@implementation Setting

+ (Setting *)settingWithComponent:(int)component value:(NSNumber *)value
{
	Setting *s = [[Setting alloc] init];
	s.component = component;
	s.value = value;
	return s;
}

- (NSString *)description
{
	const char *prefixes[] = { "aperture: ", "shutter: ", "sensitivity: " };
	return [NSString stringWithFormat:@"%s%@", prefixes[self.component],
			[Setting formatSettingWithComponent:self.component value:self.value]];
}

// This display logic might more properly belong in the view controller, but having it here
// means that it can be used for debugger display as well (see the description method above).
+ (NSString *)formatSettingWithComponent:(int)component value:(NSNumber *)value
{
	switch (component) {
		case 0:
			return [self formatAperture:value];
		case 1:
			return [self formatShutterSpeed:value];
		case 2:
			return [self formatSensitivity:value];
		default:
			@throw [NSException exceptionWithName:@"Invalid argument"
										   reason:@"Component out of range"
										 userInfo:nil];
	}
}

+ (NSString *)formatAperture:(NSNumber *)aperture
{
	return [NSString stringWithFormat:@"f/%@", aperture];
}

+ (NSString *)formatShutterSpeed:(NSNumber *)boxedSpeed
{
	double speed = [boxedSpeed doubleValue];
	
	if (speed == 60) {
		return @"1m";
	} else if (speed > 60) {
		int minutes = (int)speed / 60;
		int seconds = lround(speed - 60 * minutes);
		
		if (seconds == 0) {
			return [NSString stringWithFormat:@"%dm", minutes];
		} else {
			return [NSString stringWithFormat:@"%dm%ds", minutes, seconds];
		}
	} else if (speed >= 10) {
		return [NSString stringWithFormat:@"%ld", lround(speed)];
	} else if (speed >= 1) {
		return [NSString stringWithFormat:@"%g", speed];
	} else {
		return [NSString stringWithFormat:@"1/%g", 1.0/speed]; // display e.g. 1.0/500.0 as "1/500"
 	}
}

+ (NSString *)formatSensitivity:(NSNumber *)iso
{
	return [iso stringValue];
}


@end

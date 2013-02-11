//
//  ConstrainedSettingsDataSource_test.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/11/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ConstrainedSettingsDataSource.h"
#import "SupportedSettings.h"
#import "Calculator.h"

@interface ConstrainedSettingsDataSource_test : SenTestCase
@end

@implementation ConstrainedSettingsDataSource_test

- (void)testLimitsToAvailableSettings
{
	NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
	NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
		[NSNumber numberWithDouble:1.0/80.0],
		[NSNumber numberWithDouble:1.0/100.0]];
	NSArray *supportedIsos = @[@100, @125, @160];
	
	SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
															   shutterSpeeds:supportedShutterSpeeds
															   sensitivities:supportedIsos];
	Calculator *calculator = [[Calculator alloc] initWithSettings:config];
	ConstrainedSettingsDataSource *target = [[ConstrainedSettingsDataSource alloc]
											 initWithCalculator:calculator];
	
	// After setting an Lv, only the settings that give that Lv should be available
	calculator.lv = [Calculator lvForAperture:4.0 shutter:1.0/60.0 sensitivity:125];
	[target update];
	NSArray *expectedApertures = @[@4.0, @4.5];
	NSArray *expectedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60], [NSNumber numberWithDouble:1.0/80]];
	NSArray *expectedIsos = @[@125, @160];
	STAssertEqualObjects(target.components[0], expectedApertures, @"Wrong apertures with Lv set");
	STAssertEqualObjects(target.components[1], expectedShutterSpeeds, @"Wrong shutter speeds with Lv set");
	STAssertEqualObjects(target.components[2], expectedIsos, @"Wrong ISOs with Lv set");
	
	// After also setting a sensitivity, only the settings that give the specified Lv at the
	// specified sensitivity should be available
	calculator.lockedSensitivity = @125;
	[target update];
	expectedApertures = @[@4.0];
	expectedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60]];
	expectedIsos = @[@125];
	STAssertEqualObjects(target.components[0], expectedApertures, @"Wrong apertures with Lv and ISO set");
	STAssertEqualObjects(target.components[1], expectedShutterSpeeds, @"Wrong shutter speeds with Lv and ISO set");
	STAssertEqualObjects(target.components[2], expectedIsos, @"Wrong ISOs with Lv and ISO set");

}

@end

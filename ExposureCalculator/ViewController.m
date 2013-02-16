//
//  ViewController.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ViewController.h"
#import "Calculator.h"
#import "ArrayDataSource.h"
#import "ConstrainedSettingsDataSource.h"
#import "SupportedSettings.h"

@interface ViewController () {
	int meteredSettings[3]; // row indices
	BOOL initializing;
}

@property (nonatomic, strong) SupportedSettings *supportedSettings;
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ArrayDataSource *meteredSettingsDataSource;
@property (nonatomic, strong) ConstrainedSettingsDataSource *chosenSettingsDataSource;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	initializing = YES;
	
	for (int i = 0; i < 3; i++) {
		meteredSettings[i] = 0;
	}
	
	self.supportedSettings = [SupportedSettings defaultSettings];
	self.calculator = [[Calculator alloc] initWithSettings:self.supportedSettings];
	self.meteredSettingsDataSource = [[ArrayDataSource alloc] init];
	self.meteredSettingsDataSource.components = @[self.supportedSettings.apertures,
		self.supportedSettings.shutterSpeeds, self.supportedSettings.sensitivities];
	self.chosenSettingsDataSource = [[ConstrainedSettingsDataSource alloc] initWithCalculator:self.calculator];
	self.meteredSettingsPicker.dataSource = self.meteredSettingsDataSource;
	self.chosenSettingsPicker.dataSource = self.chosenSettingsDataSource;
	
	// Set some reasonable defaults
	meteredSettings[0] = [self.supportedSettings.apertures indexOfObject:@4.0];
	meteredSettings[1] = [self.supportedSettings.shutterSpeeds
						  indexOfObject:[NSNumber numberWithDouble:1.0/30.0]];
	meteredSettings[2] = [self.supportedSettings.sensitivities indexOfObject:@1600];
	[self.meteredSettingsPicker selectRow:meteredSettings[0] inComponent:0 animated:NO];
	[self.meteredSettingsPicker selectRow:meteredSettings[1] inComponent:1 animated:NO];
	[self.meteredSettingsPicker selectRow:meteredSettings[2] inComponent:2 animated:NO];
	
	initializing = NO;
	[self recalculate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	ArrayDataSource *dataSource = (ArrayDataSource *)pickerView.dataSource;
	NSNumber *value = dataSource.components[component][row];

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

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component
{
	if (pickerView == self.meteredSettingsPicker) {
		meteredSettings[component] = row;
		[self recalculate];
	} else {
		// Lock the aperture/shutter/sensitivity to the selected one
		// We could do this with an array of selectors, but with the necessary ARC warning cruft
		// that version ends up uglier than this one.
		switch (component) {
			case 0:
				self.calculator.lockedAperture = self.supportedSettings.apertures[row];
				break;
				
			case 1:
				self.calculator.lockedShutterSpeed = self.supportedSettings.shutterSpeeds[row];
				break;
				
			case 2:
				self.calculator.lockedSensitivity = self.supportedSettings.sensitivities[row];
				break;
				
			default:
				@throw [NSException exceptionWithName:@"Invalid argument"
											   reason:@"Component out of range"
											 userInfo:nil];
		}
		
		[self recalculateChosenSettings];
	}
}


#pragma mark -
				
- (NSString *)formatAperture:(NSNumber *)aperture
{
	return [NSString stringWithFormat:@"f/%@", aperture];
}

- (NSString *)formatShutterSpeed:(NSNumber *)boxedSpeed
{
	double speed = [boxedSpeed doubleValue];
	
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

- (NSString *)formatSensitivity:(NSNumber *)iso
{
	return [iso stringValue];
}

- (void)recalculate
{
	if (initializing) {
		return;
	}
	
	double aperture = [[self.supportedSettings.apertures objectAtIndex:meteredSettings[0]]
					   doubleValue];
	double shutter = [[self.supportedSettings.shutterSpeeds objectAtIndex:meteredSettings[1]]
					  doubleValue];
	int iso = [[self.supportedSettings.sensitivities objectAtIndex:meteredSettings[2]] intValue];
	self.calculator.lv = [Calculator lvForAperture:aperture shutter:shutter sensitivity:iso];
	[self recalculateChosenSettings];
}

- (void)recalculateChosenSettings
{
	[self.chosenSettingsDataSource update];
	[self.chosenSettingsPicker reloadAllComponents];
}

- (IBAction)unlockAperture:(id)ignored
{
	self.calculator.lockedAperture = nil;
	[self recalculateChosenSettings];
}

- (IBAction)unlockShutter:(id)ignored
{
	self.calculator.lockedShutterSpeed = nil;
	[self recalculateChosenSettings];
}

- (IBAction)unlockSensitivity:(id)ignored
{
	self.calculator.lockedSensitivity = nil;
	[self recalculateChosenSettings];
}


@end

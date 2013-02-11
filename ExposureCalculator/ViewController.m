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
#import "SupportedSettings.h"

@interface ViewController () {
	int selectedSettings[3]; // row indices
	BOOL initializing;
}

@property (nonatomic, strong) SupportedSettings *supportedSettings;
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ArrayDataSource *meteredSettings;
@property (nonatomic, strong) ArrayDataSource *chosenSettings;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	initializing = YES;
	
	for (int i = 0; i < 3; i++) {
		selectedSettings[i] = 0;
	}
	
	self.supportedSettings = [SupportedSettings defaultSettings];
	self.calculator = [[Calculator alloc] initWithSettings:self.supportedSettings];
	self.meteredSettings = [[ArrayDataSource alloc] init];
	self.meteredSettings.components = @[self.supportedSettings.apertures,
		self.supportedSettings.shutterSpeeds, self.supportedSettings.sensitivities];
	self.chosenSettings = [[ArrayDataSource alloc] init];  // Will be configured later
	self.meteredSettingsPicker.dataSource = self.meteredSettings;
	self.chosenSettingsPicker.dataSource = self.chosenSettings;
	
	// Set some reasonable defaults
	[self.meteredSettingsPicker selectRow:[self.supportedSettings.apertures indexOfObject:@4.0]
							  inComponent:0 animated:NO];
	[self.meteredSettingsPicker selectRow:[self.supportedSettings.shutterSpeeds
										   indexOfObject:[NSNumber numberWithDouble:1.0/30.0]]
							  inComponent:1 animated:NO];
	[self.meteredSettingsPicker selectRow:[self.supportedSettings.sensitivities indexOfObject:@1600]
							  inComponent:2 animated:NO];
	
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
	
	if (pickerView == self.meteredSettingsPicker) {
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
	} else {
		NSDictionary *settings = dataSource.components[component][row];
		return [NSString stringWithFormat:@"%@, %@, ISO %@",
				[self formatAperture:settings[@"aperture"]],
				[self formatShutterSpeed:settings[@"shutterSpeed"]],
				[self formatSensitivity:settings[@"sensitivity"]]];
	}
}

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component
{
	if (pickerView == self.meteredSettingsPicker) {
		selectedSettings[component] = row;
		[self recalculate];
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
	
	double aperture = [[self.supportedSettings.apertures objectAtIndex:selectedSettings[0]] doubleValue];
	double shutter = [[self.supportedSettings.shutterSpeeds objectAtIndex:selectedSettings[1]] doubleValue];
	int iso = [[self.supportedSettings.sensitivities objectAtIndex:selectedSettings[2]] intValue];
	self.calculator.lv = [Calculator lvForAperture:aperture shutter:shutter sensitivity:iso];
	NSArray *validSettings = [self.calculator validSettings];
	self.chosenSettings.components = @[validSettings];
	[self.chosenSettingsPicker reloadAllComponents];
}


@end

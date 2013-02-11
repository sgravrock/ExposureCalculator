//
//  ViewController.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ViewController.h"
#import "SettingsDataSource.h"

@interface ViewController ()
@property (nonatomic, strong) SettingsDataSource *meteredSettings;
@property (nonatomic, strong) SettingsDataSource *chosenSettings;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.meteredSettings = [[SettingsDataSource alloc] init];
	self.meteredSettingsPicker.dataSource = self.meteredSettings;
	self.chosenSettings = [[SettingsDataSource alloc] init];
	self.chosenSettingsPicker.dataSource = self.chosenSettings;
	
	// Set some reasonable defaults
	[self.meteredSettingsPicker selectRow:[self.meteredSettings.apertures indexOfObject:[NSNumber numberWithDouble:4.0]] inComponent:0 animated:NO];
	[self.meteredSettingsPicker selectRow:[self.meteredSettings.shutterSpeeds indexOfObject:[NSNumber numberWithDouble:1.0/30.0]] inComponent:1 animated:NO];
	[self.meteredSettingsPicker selectRow:[self.meteredSettings.isos indexOfObject:@1600] inComponent:2 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	SettingsDataSource *dataSource = (SettingsDataSource *)pickerView.dataSource;
	
	switch (component) {
		case 0:
			return [NSString stringWithFormat:@"f/%@", dataSource.apertures[row]];
		case 1:
			return [self formatShutterSpeed:[dataSource.shutterSpeeds[row] doubleValue]];
		case 2:
			return [dataSource.isos[row] stringValue];
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

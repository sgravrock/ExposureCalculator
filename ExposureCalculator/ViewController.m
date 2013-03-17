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
#import "Setting.h"

@interface ViewController () {
	int meteredSettings[3]; // row indices
}

@property (nonatomic, strong) SupportedSettings *supportedSettings;
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ArrayDataSource *meteredSettingsDataSource;
@property (nonatomic, strong) ChosenSettingsModel *chosenSettings;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	for (int i = 0; i < 3; i++) {
		meteredSettings[i] = 0;
	}
	
	self.supportedSettings = [[SupportedSettings alloc] init];
	self.calculator = [[Calculator alloc] initWithSettings:self.supportedSettings];
	self.meteredSettingsDataSource = [[ArrayDataSource alloc] init];
	self.meteredSettingsDataSource.components = @[self.supportedSettings.apertures,
		self.supportedSettings.shutterSpeeds, self.supportedSettings.sensitivities];
	self.meteredSettingsPicker.dataSource = self.meteredSettingsDataSource;
	
	// Set some reasonable defaults
	meteredSettings[0] = [self.supportedSettings.apertures indexOfObject:@4.0];
	meteredSettings[1] = [self.supportedSettings.shutterSpeeds
						  indexOfObject:[NSNumber numberWithDouble:1.0/30.0]];
	meteredSettings[2] = [self.supportedSettings.sensitivities indexOfObject:@1600];
	[self.meteredSettingsPicker selectRow:meteredSettings[0] inComponent:0 animated:NO];
	[self.meteredSettingsPicker selectRow:meteredSettings[1] inComponent:1 animated:NO];
	[self.meteredSettingsPicker selectRow:meteredSettings[2] inComponent:2 animated:NO];
	
	self.chosenSettings = [[ChosenSettingsModel alloc] initWithCalculator:self.calculator];
	self.chosenSettings.delegate = self;
	self.chosenSettingsPicker.dataSource = self.chosenSettings.dataSource;
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
	return [Setting formatSettingWithComponent:component value:value];
}

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component
{	
	if (pickerView == self.meteredSettingsPicker) {
		meteredSettings[component] = row;
		[self recalculate];
	} else {
		switch (component) {
			case 0:
				[self.chosenSettings selectAperture:row];
				break;
				
			case 1:
				[self.chosenSettings selectShutter:row];
				break;
				
			case 2:
				[self.chosenSettings selectSensitivity:row];
				break;
				
			default:
				@throw [NSException exceptionWithName:@"Invalid argument"
											   reason:@"Component out of range"
											 userInfo:nil];
		}
	}
}

- (UIView *)pickerView:(UIPickerView *)pickerView
			viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component
		   reusingView:(UIView *)view
{
	UILabel* label = (UILabel*)view;
	
	if (!label) {
		label = [[UILabel alloc] init];
	}
	
	label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}


#pragma mark -

- (void)recalculate
{
	double aperture = [[self.supportedSettings.apertures objectAtIndex:meteredSettings[0]]
					   doubleValue];
	double shutter = [[self.supportedSettings.shutterSpeeds objectAtIndex:meteredSettings[1]]
					  doubleValue];
	int iso = [[self.supportedSettings.sensitivities objectAtIndex:meteredSettings[2]] intValue];
	int lv = [Calculator thirdsLvForAperture:aperture shutter:shutter sensitivity:iso];
	self.calculator.thirdsLv = lv;
	[self.chosenSettingsPicker reloadAllComponents];
}

#pragma mark - ChosenSettingsModelDelegate

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedApertureToIndex:(int)index
{
	[self.chosenSettingsPicker selectRow:index inComponent:0 animated:YES];
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedShutterToIndex:(int)index
{
	[self.chosenSettingsPicker selectRow:index inComponent:1 animated:YES];
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedSensitivityToIndex:(int)index
{
	[self.chosenSettingsPicker selectRow:index inComponent:2 animated:YES];
}

@end

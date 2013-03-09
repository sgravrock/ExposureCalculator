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
#import "ChosenSetting.h"

@interface ViewController () {
	int meteredSettings[3]; // row indices
	BOOL updating;
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
	
	updating = YES;
	
	for (int i = 0; i < 3; i++) {
		meteredSettings[i] = 0;
	}
	
	self.supportedSettings = [SupportedSettings defaultSettings];
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
	updating = NO;
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
	return [ChosenSetting formatSettingWithComponent:component value:value];
}

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component
{
	NSLog(@"didSelectRow:%d inComponent:%d", row, component);
	
	if (pickerView == self.meteredSettingsPicker) {
		meteredSettings[component] = row;
		[self recalculate];
	} else {
		// TODO: probably don't need this check
		if (updating) {
			return;
		}
		
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



#pragma mark -

- (void)recalculate
{
	if (updating) {
		return;
	}
	
	double aperture = [[self.supportedSettings.apertures objectAtIndex:meteredSettings[0]]
					   doubleValue];
	double shutter = [[self.supportedSettings.shutterSpeeds objectAtIndex:meteredSettings[1]]
					  doubleValue];
	int iso = [[self.supportedSettings.sensitivities objectAtIndex:meteredSettings[2]] intValue];
	self.calculator.lv = [Calculator lvForAperture:aperture shutter:shutter sensitivity:iso];
}

#pragma mark - ChosenSettingsModelDelegate

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedApertureToIndex:(int)index
{
	updating = YES;
	[self.chosenSettingsPicker selectRow:index inComponent:0 animated:YES];
	updating = NO;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedShutterToIndex:(int)index
{
	updating = YES;
	[self.chosenSettingsPicker selectRow:index inComponent:1 animated:YES];
	updating = NO;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedSensitivityToIndex:(int)index
{
	updating = YES;
	[self.chosenSettingsPicker selectRow:index inComponent:2 animated:YES];
	updating = NO;
}

@end

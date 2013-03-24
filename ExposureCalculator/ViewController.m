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

@interface ViewController ()
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ArrayDataSource *meteredSettingsDataSource;
@property (nonatomic, strong) NSMutableArray *selectedMeteredSettings; // of NSNumber
@property (nonatomic, strong) ChosenSettingsModel *chosenSettings;
@end

@implementation ViewController
@synthesize configuration;

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	self.configuration = [[SupportedSettings alloc] init];
	self.calculator = [[Calculator alloc] initWithSettings:self.configuration];
	self.meteredSettingsDataSource = [[ArrayDataSource alloc] init];
	self.meteredSettingsDataSource.components = self.configuration.components;
	self.meteredSettingsPicker.dataSource = self.meteredSettingsDataSource;
	
	// Set some reasonable defaults
	// TODO: Once we start saving & restoring configuration, filter these to within the allowed settings.
	self.selectedMeteredSettings = [NSMutableArray arrayWithArray:@[@4, @(1.0/30.0), @1600]];
	
	for (int i = 0; i < 3; i++) {
		int rowIx = [self indexOfValue:self.selectedMeteredSettings[i] inComponent:i];
		[self.meteredSettingsPicker selectRow:rowIx inComponent:i animated:NO];
	}
	
	self.chosenSettings = [[ChosenSettingsModel alloc] initWithCalculator:self.calculator];
	self.chosenSettings.delegate = self;
	self.chosenSettingsPicker.dataSource = self.chosenSettings.dataSource;
	[self recalculate];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super encodeRestorableStateWithCoder:coder];
	[coder encodeObject:self.configuration forKey:@"configuration"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super decodeRestorableStateWithCoder:coder];
	SupportedSettings *config = [coder decodeObjectForKey:@"configuration"];
	
	if (config) {
		self.configuration = self.calculator.supportedSettings = config;
		[self applyConfigurationChange];
	}
}



#pragma mark - Configuration UI support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// The only segue we use is to the settings view. Before it's performed, we need to let
	// the settings view know about us so it can get the current settings and let us know
	// when it's done.
	[segue.destinationViewController setDelegate:self];
}

- (void)configViewControllerShouldClose:(ConfigViewController *)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		[self applyConfigurationChange];
	}];
}

- (void)applyConfigurationChange
{
	self.meteredSettingsDataSource.components = self.configuration.components;
	[self.meteredSettingsPicker reloadAllComponents];
	
	
	// Because the range of settings may have changed, we need to re-select each setting.
	// Additionally, the previously-selected settings may be out of the new configured range.
	for (int i = 0; i < 3; i++) {
		int rowIx = [self indexOfValue:self.selectedMeteredSettings[i] inComponent:i];
		
		if (rowIx == NSNotFound) {
			rowIx = 0;
			self.selectedMeteredSettings[i] = [self valueForRow:0 inComponent:i];
		}
		
		[self.meteredSettingsPicker selectRow:rowIx inComponent:i animated:NO];
	}
	
	[self recalculate];
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
		[self.selectedMeteredSettings setObject:[self valueForRow:row inComponent:component]
							 atIndexedSubscript:component];
		[self recalculate];
	} else {
		[self.chosenSettings selectIndex:row forComponent:component];
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

- (NSNumber *)valueForRow:(int)rowIx inComponent:(int)componentIx
{
	return self.configuration.components[componentIx][rowIx];
}

- (int)indexOfValue:(NSNumber *)value inComponent:(int)componentIx
{
	return [self.configuration.components[componentIx] indexOfObject:value];
}

- (void)recalculate
{
	double aperture = [self.selectedMeteredSettings[kApertureComponent] doubleValue];
	double shutter = [self.selectedMeteredSettings[kShutterComponent] doubleValue];
	int iso = [self.selectedMeteredSettings[kSensitivityComponent] intValue];
	self.calculator.thirdsLv = [Calculator thirdsLvForAperture:aperture
													   shutter:shutter
												   sensitivity:iso];
	[self.chosenSettingsPicker reloadAllComponents];
}

#pragma mark - ChosenSettingsModelDelegate

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender
		   changedComponent:(int)component
					toIndex:(int)index
{
	[self.chosenSettingsPicker selectRow:index inComponent:component animated:YES];
}

@end

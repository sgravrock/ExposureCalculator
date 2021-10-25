//
//  MainViewController.,
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "MainViewController.h"
#import "Calculator.h"
#import "ArrayDataSource.h"
#import "ConstrainedSettingsDataSource.h"
#import "SupportedSettings.h"
#import "Setting.h"
#import "ConfigViewController.h"
#import "ExposureCalculator-Swift.h"

@interface MainViewController ()
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ArrayDataSource *meteredSettingsDataSource;
@property (nonatomic, strong) NSMutableArray *selectedMeteredSettings; // of NSNumber
@property (nonatomic, strong) ChosenSettingsModel *chosenSettings;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	self.configuration = [[SupportedSettings alloc] init];
	self.calculator = [[Calculator alloc] initWithSettings:self.configuration];
	self.meteredSettingsDataSource = [[ArrayDataSource alloc] init];
	self.meteredSettingsDataSource.components = self.configuration.components;
	self.meteredSettingsPicker.dataSource = self.meteredSettingsDataSource;
	
	// Set some reasonable defaults
	self.selectedMeteredSettings = [NSMutableArray arrayWithArray:@[@4, @(1.0/30.0), @1600]];
	
	for (int i = 0; i < 3; i++) {
		NSUInteger rowIx = [self indexOfValue:self.selectedMeteredSettings[i] inComponent:i];
		[self.meteredSettingsPicker selectRow:rowIx inComponent:i animated:NO];
	}
	
	self.chosenSettings = [[ChosenSettingsModel alloc] initWithCalculator:self.calculator];
	self.chosenSettings.delegate = self;
	self.chosenSettingsPicker.dataSource = self.chosenSettings.dataSource;
	[self recalculate];
}

- (IBSegueAction UIViewController *)showSwiftUiSettings:(NSCoder *)coder {
    return [ConfigViewHostingWrapperFactory makeWithCoder:coder];
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self applyConfigurationChange]; // in case we're coming back from settings
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // TODO: Fix this so it works with the SwiftUI view
    
	// The only segue we use is to the settings view. Before it's performed, we need to let
	// the settings view know about us so it can get the current settings and let us know
	// when it's done.
//	ConfigViewController *dest = segue.destinationViewController;
//	dest.configuration = self.configuration;
}

- (void)applyConfigurationChange
{
	self.meteredSettingsDataSource.components = self.configuration.components;
	[self.meteredSettingsPicker reloadAllComponents];
	
	
	// Because the range of settings may have changed, we need to re-select each setting.
	// Additionally, the previously-selected settings may be out of the new configured range.
	for (int i = 0; i < 3; i++) {
		NSUInteger rowIx = [self indexOfValue:self.selectedMeteredSettings[i] inComponent:i];
		
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
	
	BOOL isIphone5 = [UIScreen mainScreen].bounds.size.height >= 568;
	// Our longest text will fit at the default 20px font on the iPhone 5, but not smaller devices.
	CGFloat size = isIphone5 ? 20 : 17;
	label.font = [UIFont boldSystemFontOfSize:size];
	label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
	label.textColor = [UIColor whiteColor];
    return label;
}


#pragma mark -

- (NSNumber *)valueForRow:(NSUInteger)rowIx inComponent:(NSUInteger)componentIx
{
	return self.configuration.components[componentIx][rowIx];
}

- (NSUInteger)indexOfValue:(NSNumber *)value inComponent:(NSUInteger)componentIx
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
		   changedComponent:(NSUInteger)component
					toIndex:(NSUInteger)index
{
	[self.chosenSettingsPicker selectRow:index inComponent:component animated:YES];
}

@end

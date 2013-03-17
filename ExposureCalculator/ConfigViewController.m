//
//  CofigurationViewController.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigViewControllerDelegate.h"
#import "MinMaxPair.h"
#import "SupportedSettings.h"
#import "Setting.h"
#import "NSArray+Functional.h"
#import "ArrayDataSource.h"

@interface ConfigViewController () {
	int selectedSetting;
}
@property (nonatomic, strong) NSArray *possibleSettings; // of ArrayDataSouce;
@property (nonatomic, strong) NSArray *selections; // of MinMaxPair;
@property (nonatomic, strong) NSArray *labels;
@end

@implementation ConfigViewController

- (void)viewDidLoad
{
	self.labels = @[@"Aperture range", @"Shutter range", @"ISO range"];
	SupportedSettings *s = [[SupportedSettings alloc] init];
	NSArray *components = @[s.apertures, s.shutterSpeeds, s.sensitivities];
	
	self.possibleSettings = [components map:^id(id it) {
		ArrayDataSource *ds = [[ArrayDataSource alloc] init];
		ds.components = @[it, it];
		return ds;
	}];
	
	self.selections = [components map:^id(id it) {
		int max = [it count] - 1;
		return [[MinMaxPair alloc] initWithLimit:max];
	}];

	NSIndexPath *initialSelection = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView selectRowAtIndexPath:initialSelection
								animated:NO
						  scrollPosition:UITableViewScrollPositionNone];
	[self tableView:self.tableView didSelectRowAtIndexPath:initialSelection];
}

- (IBAction)close:(id)sender
{
	// Update the configuration with the user's selections. Then tell the delegate that we're done.
	SEL selectors[] = { @selector(includeAperturesFrom:to:),
		@selector(includeShutterSpeedsFrom:to:),
		@selector(includeSensitivitiesFrom:to:)
	};
	SupportedSettings *config = self.delegate.configuration;
	
	for (int i = 0; i < 3; i++) {
		ArrayDataSource *ds = self.possibleSettings[i];
		NSArray *values = ds.components[0];
		MinMaxPair *selected = self.selections[i];
		NSNumber *min = values[selected.min];
		NSNumber *max = values[selected.max];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[config performSelector:selectors[i] withObject:min withObject:max];
#pragma clang diagnostic pop
	}
	
	[self.delegate configViewControllerShouldClose:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												   reuseIdentifier:@"cell"];
	cell.textLabel.text = self.labels[indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Initialize the picker view based on whatever was just selected in the table view
	// (aperture, shutter or ISO)
	selectedSetting = indexPath.row;
	self.pickerView.dataSource = self.possibleSettings[selectedSetting];
	[self.pickerView reloadAllComponents];
	[self.pickerView selectRow:[self.selections[selectedSetting] min] inComponent:0 animated:NO];
	[self.pickerView selectRow:[self.selections[selectedSetting] max] inComponent:1 animated:NO];
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	// Both components show the same setting (aperture, shutter, or ISO).
	ArrayDataSource *src = self.possibleSettings[selectedSetting];
	NSNumber *value = src.components[0][row];
	return [Setting formatSettingWithComponent:selectedSetting value:value];
}

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component
{
	MinMaxPair *currentSettingSelections = self.selections[selectedSetting];

	if (component == 0) {
		currentSettingSelections.min = row;
		[pickerView selectRow:currentSettingSelections.max inComponent:1 animated:YES];
	} else {
		currentSettingSelections.max = row;
		[pickerView selectRow:currentSettingSelections.min inComponent:0 animated:YES];
	}
}

@end

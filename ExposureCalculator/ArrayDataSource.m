//
//  ArrayDataSource.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ArrayDataSource.h"

@implementation ArrayDataSource

- (id)init
{
	self = [super init];
	
	if (self) {
		self.components = [NSArray array];
	}
	
	return self;
}

#pragma mark - UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return self.components.count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSArray *c = self.components[component];
	return c.count;
}


@end

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

- (void)setComponents:(NSArray *)value
{
	for (id c in value) {
		if (![c isKindOfClass:[NSArray class]]) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:@"ArrayDataSource components must be arrays"
										 userInfo:nil];
		}
	}
	
	_components = value;
}

#pragma mark - UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return self.components.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSArray *c = self.components[component];
	return c.count;
}


@end

//
//  ConstrainedSettingsDataSource.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ConstrainedSettingsDataSource.h"
#import "Calculator.h"
#import "components.h"

@interface ConstrainedSettingsDataSource()
@property (nonatomic, strong) Calculator *calculator;
@end

@implementation ConstrainedSettingsDataSource

- (id)initWithCalculator:(Calculator *)calculator
{
	self = [super init];
	
	if (self) {
		self.calculator = calculator;
		[self update];
	}
	
	return self;
}

- (void)update
{
	NSArray *availableSettings = @[[NSMutableSet set], [NSMutableSet set], [NSMutableSet set]];
	
	for (NSArray *setting in [self.calculator validSettings]) {
		for (int i = 0; i < 3; i++) {
			[availableSettings[i] addObject:setting[i]];
		}
	}
	
	self.components = @[[self sortedArrayFromSet:availableSettings[0] forComponent:0],
		[self sortedArrayFromSet:availableSettings[1] forComponent:1],
		[self sortedArrayFromSet:availableSettings[2] forComponent:2]];
}

- (NSArray *)sortedArrayFromSet:(NSSet *)set forComponent:(int)component
{
	BOOL ascending = component == kApertureComponent;
	NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:ascending];
	return [set sortedArrayUsingDescriptors:@[d]];
}

@end

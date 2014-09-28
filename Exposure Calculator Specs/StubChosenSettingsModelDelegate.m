//
//  StubChosenSettingsModelDelegate.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "StubChosenSettingsModelDelegate.h"

@implementation StubChosenSettingsModelDelegate

- (id)init
{
	self = [super init];
	
	if (self) {
		for (int i = 0; i < 3; i++) {
			settings[i] = -1;
		}
	}
	
	return self;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender
		   changedComponent:(NSUInteger)component
					toIndex:(NSUInteger)index
{
	settings[component] = index;
}

@end

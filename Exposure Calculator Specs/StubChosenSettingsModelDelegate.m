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
		self.apertureIx = self.shutterSpeedIx = self.sensitivityIx = -1;
	}
	
	return self;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedApertureToIndex:(int)index
{
	self.apertureIx = index;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedShutterToIndex:(int)index
{
	self.shutterSpeedIx = index;
}

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedSensitivityToIndex:(int)index
{
	self.sensitivityIx = index;
}



@end

//
//  ExposureSettings.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ExposureSettings.h"

@implementation ExposureSettings

+ (ExposureSettings *)settingsWithAperture:(double)fNumber
								   shutter:(double)seconds
							   sensitivity:(int)iso
{
	return [[ExposureSettings alloc] initWithAperture:fNumber shutter:seconds sensitivity:iso];
}

- (id)init
{
	@throw [NSException exceptionWithName:@"Wrong initializer"
								   reason:@"ExposureSettings's designated intializer was not called"
								 userInfo:nil];
}

- (id)initWithAperture:(double)fNumber
			   shutter:(double)seconds
		   sensitivity:(int)iso
{
	self = [super init];
	
	if (self) {
		self.aperture = fNumber;
		self.shutterSpeed = seconds;
		self.sensitivity = iso;
	}
	
	return self;
}

@end

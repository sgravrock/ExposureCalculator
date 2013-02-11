//
//  ExposureSettings.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

// A simple immutable property bag that represents a set of exposure settings
@interface ExposureSettings : NSObject

+ (ExposureSettings *)settingsWithAperture:(double)fNumber
								   shutter:(double)seconds
							   sensitivity:(int)iso;
- (id)initWithAperture:(double)fNumber
			   shutter:(double)seconds
		   sensitivity:(int)iso;

@property (nonatomic) double aperture;
@property (nonatomic) double shutterSpeed;
@property (nonatomic) int sensitivity;

@end

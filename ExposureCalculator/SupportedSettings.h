//
//  SupportedSettings.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportedSettings : NSObject

+ (SupportedSettings *)defaultSettings;

- (id)initWithApertures:(NSArray *)apertures
		  shutterSpeeds:(NSArray *)shutterSpeeds
		  sensitivities:(NSArray *)sensitivities;

// Apertures as doubles, e.g. f/2.8 is stored as 2.8
@property (nonatomic, readonly, strong) NSArray *apertures;
// Shutter speeds as doubles, in seconds
@property (nonatomic, readonly, strong) NSArray *shutterSpeeds;
// ISO sensitivities as integers
@property (nonatomic, readonly, strong) NSArray *sensitivities;

@end

//
//  SupportedSettings.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportedSettings : NSObject

// Apertures as doubles, e.g. f/2.8 is stored as 2.8
+ (NSArray *)apertures;
// Shutter speeds as doubles, in seconds
+ (NSArray *)shutterSpeeds;
// ISO sensitivities as integers
+ (NSArray *)sensitivities;

@end

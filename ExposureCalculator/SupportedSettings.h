//
//  SupportedSettings.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportedSettings : NSObject

// Constructs a SupportedSettings object set to the full range of possible settings.
- (id)init;

// Apertures as doubles, e.g. f/2.8 is stored as 2.8
@property (nonatomic, readonly, strong) NSArray *apertures;

// Shutter speeds as doubles, in seconds
@property (nonatomic, readonly, strong) NSArray *shutterSpeeds;

// ISO sensitivities as integers
@property (nonatomic, readonly, strong) NSArray *sensitivities;

// include* methods configure the receiver to include the possible settings that are between
// the specified minimum and maximum.
- (void)includeAperturesFrom:(NSNumber *)min to:(NSNumber *)max;
- (void)includeShutterSpeedsFrom:(NSNumber *)min to:(NSNumber *)max;
- (void)includeSensitivitiesFrom:(NSNumber *)min to:(NSNumber *)max;


@end

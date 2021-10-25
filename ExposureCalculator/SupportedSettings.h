//
//  SupportedSettings.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "components.h"

@interface SupportedSettings : NSObject<NSSecureCoding>

// Constructs a SupportedSettings object set to the full range of possible settings.
- (id)init;

// Each component is itself an NSArray, with values as follows:
// Apertures are doubles, e.g. f/2.8 is stored as 2.8
// Shutter speeds are doubles, in seconds
// ISO sensitivities are integers
@property (nonatomic, readonly, strong) NSArray<NSArray<NSNumber *> *> *components;

// Configures the receiver to include the possible settings that are between
// the specified minimum and maximum.
- (void)includeValuesFrom:(NSNumber *)min to:(NSNumber *)max inComponent:(int)component;

@end

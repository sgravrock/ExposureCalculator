//
//  Calculator.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SupportedSettings;

@interface Calculator : NSObject

// Returns the light value for the specified exposure settings, in thirds of a stop.
+ (int)lvForAperture:(double)fNumber shutter:(double)seconds sensitivity:(int)iso;

@property (nonatomic, readonly, strong) SupportedSettings *supportedSettings;
@property (nonatomic) int lv;
@property (nonatomic, strong) NSNumber *lockedAperture;
@property (nonatomic, strong) NSNumber *lockedShutterSpeed;
@property (nonatomic, strong) NSNumber *lockedSensitivity;

- (id)initWithSettings:(SupportedSettings *)settings;
- (NSArray *)validSettings;

@end

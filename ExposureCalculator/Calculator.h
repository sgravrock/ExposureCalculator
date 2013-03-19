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
+ (int)thirdsLvForAperture:(double)fNumber shutter:(double)seconds sensitivity:(int)iso;

@property (nonatomic, strong) SupportedSettings *supportedSettings;
@property (nonatomic) int thirdsLv;

- (id)initWithSettings:(SupportedSettings *)settings;
- (NSArray *)validSettings;

@end

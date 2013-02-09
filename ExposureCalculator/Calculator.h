//
//  Calculator.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

+ (int)lvForAperture:(double)fNumber shutter:(double)seconds sensitivity:(int)iso;

@end

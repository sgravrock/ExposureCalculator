//
//  MinMaxPair.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinMaxPair : NSObject

- (id)initWithMin:(NSUInteger)min max:(NSUInteger)max;

@property (nonatomic, assign) NSUInteger min;
@property (nonatomic, assign) NSUInteger max;

@end

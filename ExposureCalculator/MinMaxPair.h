//
//  MinMaxPair.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinMaxPair : NSObject

- (id)initWithLimit:(int)theLimit;

@property (nonatomic, assign) int min;
@property (nonatomic, assign) int max;

@end

//
//  ConstrainedSettingsDataSource.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrayDataSource.h"
@class Calculator;

@interface ConstrainedSettingsDataSource : ArrayDataSource<NSArray<NSNumber *> *>

- (id)initWithCalculator:(Calculator *)calculator;
- (void)update;

@end

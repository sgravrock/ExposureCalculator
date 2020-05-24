//
//  NSArray+Functional.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<T> (Functional)

- (NSArray<T> *)map:(T(^)(T it))mapper;

@end

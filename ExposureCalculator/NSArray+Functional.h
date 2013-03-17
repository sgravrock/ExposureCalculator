//
//  NSArray+Functional.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)map:(id(^)(id it))mapper;

@end

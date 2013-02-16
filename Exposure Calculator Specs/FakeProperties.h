//
//  FakeProperties.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

@protocol CedarDouble;

@interface FakeProperties : NSObject

// Adds a standard (variable-like) implementation of the specified property.
+ (void)stubProperty:(const char *)propName onObject:(id<CedarDouble>)target;

@end

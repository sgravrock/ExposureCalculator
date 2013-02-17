//
//  CliUtils.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CliUtils : NSObject

+ (NSNumber *)shutterFromString:(const char *)s;
+ (NSNumber *)apertureFromString:(const char *)s;
+ (NSNumber *)intFromString:(const char *)s;

@end

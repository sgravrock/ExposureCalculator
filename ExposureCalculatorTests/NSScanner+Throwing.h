//
//  NSScanner+Throwing.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSScanner (Throwing)

- (int)requireInt;
- (double)requireDouble;

@end

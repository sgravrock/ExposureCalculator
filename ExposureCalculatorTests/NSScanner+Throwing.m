//
//  NSScanner+Throwing.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "NSScanner+Throwing.h"

@implementation NSScanner (Throwing)

- (int)requireInt
{
	int result;
	
	if (![self scanInt:&result]) {
		NSString *msg = [NSString stringWithFormat:@"Expected a string containing an integer "
						 "but got %@", self.string];
		@throw [NSException exceptionWithName:@"Scan failed" reason:msg userInfo:nil];
	}
	
	return result;
}

- (double)requireDouble
{
	double result;
	
	if (![self scanDouble:&result]) {
		NSString *msg = [NSString stringWithFormat:@"Expected a string containing a double "
						 "but got %@", self.string];
		@throw [NSException exceptionWithName:@"Scan failed" reason:msg userInfo:nil];
	}
	
	return result;
}

@end

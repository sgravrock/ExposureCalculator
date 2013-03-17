//
//  NSArray+Functional.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)map:(id(^)(id))mapper
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
	
	for (id it in self) {
		[result addObject:mapper(it)];
	}
	
	return result;
}

@end

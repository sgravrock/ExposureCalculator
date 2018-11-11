//
//  SupportedSettings.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "SupportedSettings.h"
#import "NSArray+Functional.h"

static NSArray *allValues;

typedef BOOL (^array_filter_predicate)(id obj, NSUInteger idx, BOOL *stop);

@interface SupportedSettings() {
	NSMutableArray *mutableComponents;
}
@end

@implementation SupportedSettings

+ (NSArray *)filterSettings:(NSArray *)src
					   from:(NSNumber *)min to:(NSNumber *)max
				  ascending:(BOOL)ascending
{
	// Swap the limits if min > max. This lets us sidestep the whole issue of whether
	// we consider an aperture greater if it has a larger F number or a larger size.
	if ([min compare:max] == NSOrderedDescending) {
		NSNumber *temp = min;
		min = max;
		max = temp;
	}
	
	array_filter_predicate notLessThanMin = ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [min compare:obj] != NSOrderedDescending;
	};
	array_filter_predicate notGreaterThanMax = ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [max compare:obj] != NSOrderedAscending;
	};
	NSUInteger firstIndex, lastIndex;
	
	if (ascending) {
		firstIndex = [src indexOfObjectPassingTest:notLessThanMin];
		lastIndex = [src indexOfObjectWithOptions:NSEnumerationReverse passingTest:notGreaterThanMax];
	} else {
		firstIndex = [src indexOfObjectPassingTest:notGreaterThanMax];
		lastIndex = [src indexOfObjectWithOptions:NSEnumerationReverse passingTest:notLessThanMin];
	}
	
	NSAssert(firstIndex != NSNotFound, @"Min setting out of range");
	NSAssert(lastIndex != NSNotFound, @"Max setting out of range");
	NSAssert(firstIndex <= lastIndex, @"Min setting > max setting");
	return [src subarrayWithRange:NSMakeRange(firstIndex, lastIndex - firstIndex + 1)];
}


+ (void)initDefaults
{
	if (allValues) {
		return;
	}
	
	NSArray *allApertures = @[@1.0, @1.1, @1.2, @1.4, @1.6, @1.8, @2.0, @2.2, @2.5,
	@2.8, @3.2, @3.5, @4.0, @4.5, @5.0, @5.6, @6.3, @7.1, @8.0,
	@9.0, @10.0, @11.0, @13.0, @14.0, @16.0, @18.0, @20.0, @22.0];
	NSArray *allSensitivities = @[@50, @64, @100, @125, @160, @200, @250, @320, @400, @500, @640,
	@800, @1000, @1250, @1600, @2000, @2500, @3200, @4000, @5000, @6400];
	
	NSMutableArray *speeds = [NSMutableArray arrayWithCapacity:63];
	
	// For shutter speeds longer than 30 seconds, calculate third-stop increments using the
	// cube root method. The accumulated error from a less accurate method would be
	// considerable. The user's camera settings most likely don't extend into this range
	// (bulb will be used instead), so we don't need to worry about matching the approximations
	// that would be displayed on the camera.
	double cbrt2 = cbrt(2);
	
	for (double i = 32 * 60; i > 30; i /= cbrt2) {
		[speeds addObject:[NSNumber numberWithDouble:i]];
	}
	
	// For speeds faster than 30 seconds, hardcode the approximations that are displayed on
	// a typical camera. The error from this is small enough that rounding Lv calculations to
	// the nearest third stop will take care of it.
	NSArray *overlappingRange = @[@30, @25, @20, @15, @13, @10, @8, @6, @5, @4, @3, @2.5, @2,
	@1.6, @1.3, @1];
	[speeds addObjectsFromArray:overlappingRange];
	
	for (NSInteger i = overlappingRange.count - 2; i >= 0; i--) {
		[speeds addObject:[NSNumber numberWithDouble:1.0/[overlappingRange[i] doubleValue]]];
	}
	
	NSArray *higher = @[@40, @50, @60, @80, @100, @125, @160, @200, @250, @320, @400,
	@500, @640, @800];
	
	for (NSNumber *n in higher) {
		[speeds addObject:[NSNumber numberWithDouble:1.0/[n doubleValue]]];
	}
	
	allValues = @[allApertures, speeds, allSensitivities];
}


- (id)init
{
	self = [super init];
	
	if (self) {
		[SupportedSettings initDefaults];
		mutableComponents = [NSMutableArray arrayWithArray:allValues];
	}
	
	return self;
}

- (NSArray *)components
{
	return mutableComponents;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)coder
{
	self = [self init];
	
	if (self) {
		NSArray *limits = [coder decodeObjectForKey:@"limits"];
		
		for (int i = 0; i < 3; i++) {
			[self includeValuesFrom:limits[i][0] to:limits[i][1] inComponent:i];
		}
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	NSArray *limits = [self.components map:^id(id it) {
		return @[it[0], [it lastObject]];
	}];
	[coder encodeObject:limits forKey:@"limits"];
}

#pragma mark -

- (void)includeValuesFrom:(NSNumber *)min to:(NSNumber *)max inComponent:(int)component
{
	NSArray *filtered = [SupportedSettings filterSettings:allValues[component]
													 from:min
													   to:max
												ascending:component != kShutterComponent];
	[mutableComponents replaceObjectAtIndex:component withObject:filtered];
}

@end

//
//  Calculator_test.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Calculator.h"
#import "NSScanner+Throwing.h"
#import "SupportedSettings.h"

@interface Calculator_test : SenTestCase
@end

@implementation Calculator_test

- (double)secondsFromShutterString:(NSString *)s
{
	if (s.length > 2 && [[s substringToIndex:2] isEqualToString:@"1/"]) {
		s = [s substringFromIndex:2];
		return 1.0/((double)[[NSScanner scannerWithString:s] requireInt]);
	} else {
		return [[NSScanner scannerWithString:s] requireInt];
	}
}

- (void)verifyLv:(int)expectedLv
	 forAperture:(NSString *)aperture
		 shutter:(NSString *)shutter
	 sensitivity:(int)sensitivity
{
	NSString *msg = [NSString stringWithFormat:@"Wrong result for f/%@, %@s, ISO %d",
					 aperture, shutter, sensitivity];
	double fNumber = [[NSScanner scannerWithString:aperture] requireDouble];
	double seconds = [self secondsFromShutterString:shutter];
	int result = [Calculator lvForAperture:fNumber shutter:seconds sensitivity:sensitivity];
	STAssertEquals(result, expectedLv, msg);

}

- (void)testSecondsFromShutterString
{
	// Verify our test gear before we use it
	STAssertEquals([self secondsFromShutterString:@"1/500"], 1.0/500.0, @"Wrong result for 1/500");
	STAssertEquals([self secondsFromShutterString:@"8"], 8.0, @"Wrong result for 8");
}

- (void)testLvEqualsEvAtIso100
{
	[self verifyLv:-6*3 forAperture:@"1.4" shutter:@"120" sensitivity:100];
	[self verifyLv:-5*3 forAperture:@"2" shutter:@"120" sensitivity:100];
	[self verifyLv:-1*3 forAperture:@"2" shutter:@"8" sensitivity:100];
	[self verifyLv:-1*3 forAperture:@"5.6" shutter:@"64" sensitivity:100];
	[self verifyLv:14*3 forAperture:@"5.6" shutter:@"1/500" sensitivity:100];
	[self verifyLv:17*3 forAperture:@"22" shutter:@"1/250" sensitivity:100];
	[self verifyLv:14*3 forAperture:@"5" shutter:@"1/640" sensitivity:100];
}

- (void)testLvAccountsForIso
{
	[self verifyLv:-2*3 forAperture:@"2" shutter:@"8" sensitivity:200];
	[self verifyLv:11*3 forAperture:@"5.6" shutter:@"1/500" sensitivity:800];
	[self verifyLv:16*3 forAperture:@"8" shutter:@"1/500" sensitivity:50];
}

- (void)testLvCalculatesThirdStops
{
	[self verifyLv:14*3+1 forAperture:@"5.6" shutter:@"1/640" sensitivity:100];
	[self verifyLv:14*3-1 forAperture:@"5" shutter:@"1/500" sensitivity:100];
}

@end

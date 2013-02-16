#import "Calculator.h"
#import "NSScanner+Throwing.h"
#import "SupportedSettings.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface CDRSpec(CalculatorSpecHelpers)
- (double)secondsFromShutterString:(NSString *)s;
- (void)verifyLv:(int)expectedLv
	 forAperture:(NSString *)aperture
		 shutter:(NSString *)shutter
	 sensitivity:(int)sensitivity;
@end



SPEC_BEGIN(CalculatorSpec)

describe(@"Calculator", ^{
	describe(@"Calculating Lv from camera settings:", ^{
		it(@"should return Lv = Ev at ISO 100", ^{
			[self verifyLv:-6*3 forAperture:@"1.4" shutter:@"120" sensitivity:100];
			[self verifyLv:-5*3 forAperture:@"2" shutter:@"120" sensitivity:100];
			[self verifyLv:-1*3 forAperture:@"2" shutter:@"8" sensitivity:100];
			[self verifyLv:-1*3 forAperture:@"5.6" shutter:@"64" sensitivity:100];
			[self verifyLv:14*3 forAperture:@"5.6" shutter:@"1/500" sensitivity:100];
			[self verifyLv:17*3 forAperture:@"22" shutter:@"1/250" sensitivity:100];
			[self verifyLv:14*3 forAperture:@"5" shutter:@"1/640" sensitivity:100];
		});
		
		it(@"should adjust for ISOs other than 100", ^{
			[self verifyLv:-2*3 forAperture:@"2" shutter:@"8" sensitivity:200];
			[self verifyLv:11*3 forAperture:@"5.6" shutter:@"1/500" sensitivity:800];
			[self verifyLv:16*3 forAperture:@"8" shutter:@"1/500" sensitivity:50];
		});
		
		it(@"should calculate third stops", ^{
			[self verifyLv:14*3+1 forAperture:@"5.6" shutter:@"1/640" sensitivity:100];
			[self verifyLv:14*3-1 forAperture:@"5" shutter:@"1/500" sensitivity:100];
		});
	});
	
	describe(@"Finding valid settings for a given Lv", ^{
		it(@"should return the set of settings that give the specified Lv", ^{
			// Use a fairly narrow range of settings, so the result isn't huge
			NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
			NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
			[NSNumber numberWithDouble:1.0/80.0],
			[NSNumber numberWithDouble:1.0/100.0]];
			NSArray *supportedIsos = @[@100, @1600];
			NSArray *expected = @[
				@{@"aperture": @4.0, @"shutterSpeed": [NSNumber numberWithDouble:1.0/100.0], @"sensitivity": @100},
				@{@"aperture": @4.5, @"shutterSpeed": [NSNumber numberWithDouble:1.0/80.0], @"sensitivity": @100},
				@{@"aperture": @5.0, @"shutterSpeed": [NSNumber numberWithDouble:1.0/60.0], @"sensitivity": @100},
			];
			
			SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
																	   shutterSpeeds:supportedShutterSpeeds
																	   sensitivities:supportedIsos];
			Calculator *target = [[Calculator alloc] initWithSettings:config];
			target.lv = [Calculator lvForAperture:4.5 shutter:1.0/80.0 sensitivity:100];
			NSArray *actual = [target validSettings];
			expect([NSSet setWithArray:actual]).to(equal([NSSet setWithArray:expected]));
		});
		
		it(@"should only use the locked aperture", ^{
			// Use a fairly narrow range of settings, so the result isn't huge
			NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
			NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
			[NSNumber numberWithDouble:1.0/80.0],
			[NSNumber numberWithDouble:1.0/100.0]];
			NSArray *supportedIsos = @[@100, @125, @160];
			NSArray *expected = @[
				@{@"aperture": @4.5, @"shutterSpeed": [NSNumber numberWithDouble:1.0/100.0], @"sensitivity": @125},
				@{@"aperture": @4.5, @"shutterSpeed": [NSNumber numberWithDouble:1.0/80.0], @"sensitivity": @100}
			];
			
			SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
																	   shutterSpeeds:supportedShutterSpeeds
																	   sensitivities:supportedIsos];
			Calculator *target = [[Calculator alloc] initWithSettings:config];
			target.lv = [Calculator lvForAperture:4.5 shutter:1.0/80.0 sensitivity:100];
			target.lockedAperture = @4.5;
			NSArray *actual = [target validSettings];
			expect([NSSet setWithArray:actual]).to(equal([NSSet setWithArray:expected]));
		});
		
		it(@"should only use the locked shutter speed", ^{
			// Use a fairly narrow range of settings, so the result isn't huge
			NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
			NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
			[NSNumber numberWithDouble:1.0/80.0],
			[NSNumber numberWithDouble:1.0/100.0]];
			NSArray *supportedIsos = @[@100, @125, @160];
			NSArray *expected = @[
				@{@"aperture": @5.0, @"shutterSpeed": [NSNumber numberWithDouble:1.0/60.0], @"sensitivity": @100},
				@{@"aperture": @5.6,  @"shutterSpeed": [NSNumber numberWithDouble:1.0/60.0], @"sensitivity": @125},
			];
			
			SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
																	   shutterSpeeds:supportedShutterSpeeds
																	   sensitivities:supportedIsos];
			Calculator *target = [[Calculator alloc] initWithSettings:config];
			target.lv = [Calculator lvForAperture:4.5 shutter:1.0/80.0 sensitivity:100];
			target.lockedShutterSpeed = [NSNumber numberWithDouble:1.0/60];
			NSArray *actual = [target validSettings];
			expect([NSSet setWithArray:actual]).to(equal([NSSet setWithArray:expected]));
		});
		
		it(@"should only use the locked sensitivity", ^{
			// Use a fairly narrow range of settings, so the result isn't huge
			NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
			NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
			[NSNumber numberWithDouble:1.0/80.0],
			[NSNumber numberWithDouble:1.0/100.0]];
			NSArray *supportedIsos = @[@100, @125, @160];
			NSArray *expected = @[
				@{@"aperture": @4.0, @"shutterSpeed": [NSNumber numberWithDouble:1.0/100.0], @"sensitivity": @100},
				@{@"aperture": @4.5, @"shutterSpeed": [NSNumber numberWithDouble:1.0/80.0], @"sensitivity": @100},
				@{@"aperture": @5.0, @"shutterSpeed": [NSNumber numberWithDouble:1.0/60.0], @"sensitivity": @100},
			];
			
			SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
																	   shutterSpeeds:supportedShutterSpeeds
																	   sensitivities:supportedIsos];
			Calculator *target = [[Calculator alloc] initWithSettings:config];
			target.lv = [Calculator lvForAperture:4.5 shutter:1.0/80.0 sensitivity:100];
			target.lockedSensitivity = @100;
			NSArray *actual = [target validSettings];
			expect([NSSet setWithArray:actual]).to(equal([NSSet setWithArray:expected]));
		});
	});
});

describe(@"Test gear", ^{
	describe(@"secondsFromShutterString:", ^{
		it(@"should convert the string to the corresponding shutter speed", ^{
			expect([self secondsFromShutterString:@"1/500"]).to(equal(1.0/500.0));
			expect([self secondsFromShutterString:@"8"]).to(equal(8.0));
		});
	});
});

SPEC_END



@implementation CDRSpec(CalculatorSpecHelpers)

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
	// TODO: improve Cedar matchers so we can pass an error message
//	NSString *msg = [NSString stringWithFormat:@"Wrong result for f/%@, %@s, ISO %d",
//					 aperture, shutter, sensitivity];
	double fNumber = [[NSScanner scannerWithString:aperture] requireDouble];
	double seconds = [self secondsFromShutterString:shutter];
	int result = [Calculator lvForAperture:fNumber shutter:seconds sensitivity:sensitivity];
	expect(result).to(equal(expectedLv));
	
}

@end

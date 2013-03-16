#import "ChosenSettingsModel.h"
#import "ConstrainedSettingsDataSource.h"
#import "cedar.h"
#import "Calculator.h"
#import "SupportedSettings.h"
#import "StubChosenSettingsModelDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ChosenSettingsModelSpec)

describe(@"ChosenSettingsModel", ^{
	__block ChosenSettingsModel *target;
	__block Calculator *calculator;
	__block StubChosenSettingsModelDelegate *delegate;
		
	void (^verifyAperture)(double) = ^(double expected) {
		NSNumber *actual = target.dataSource.components[0][delegate.apertureIx];
		expect([actual doubleValue]).to(equal(expected));
	};

	void (^verifyShutterSpeed)(double) = ^(double expected) {
		NSNumber *actual = target.dataSource.components[1][delegate.shutterSpeedIx];
		expect([actual doubleValue]).to(equal(expected));
	};

	void (^verifySensitivity)(int) = ^(int expected) {
		NSNumber *actual = target.dataSource.components[2][delegate.sensitivityIx];
		expect([actual doubleValue]).to(equal(expected));
	};
	
	void (^verifySettings)(double, double, int) = ^(double aperture, double shutter, int sensitivity) {
		verifyAperture(aperture);
		verifyShutterSpeed(shutter);
		verifySensitivity(sensitivity);
	};

	void (^selectAperture)(double) = ^(double aperture) {
		int i = [target.dataSource.components[0] indexOfObject:[NSNumber numberWithDouble:aperture]];
		NSAssert(i != NSNotFound, @"Couldn't find aperture");
		[target selectAperture:i];
	};
	
	void (^selectShutterSpeed)(double) = ^(double shutter) {
		int i = [target.dataSource.components[1] indexOfObject:[NSNumber numberWithDouble:shutter]];
		NSAssert(i != NSNotFound, @"Couldn't find shutter speed");
		[target selectShutter:i];
	};
	
	void (^selectSensitivity)(int) = ^(int iso) {
		int i = [target.dataSource.components[2] indexOfObject:[NSNumber numberWithInt:iso]];
		NSAssert(i != NSNotFound, @"Couldn't find sensitivity");
		[target selectSensitivity:i];
	};
	
	beforeEach(^{
		calculator = [[Calculator alloc] initWithSettings:[[SupportedSettings alloc] init]];
		target = [[ChosenSettingsModel alloc] initWithCalculator:calculator];
		delegate = [[StubChosenSettingsModelDelegate alloc] init];
		target.delegate = delegate;
	});
	
	afterEach(^{
		[target release];
		target = nil;
		[delegate release];
		delegate = nil;
		[calculator release];
		calculator = nil;
	});
	
	describe(@"Responding to Lv changes", ^{
		describe(@"When there are no existing selections", ^{
			it(@"should select the first compatible settings", ^{
				calculator.thirdsLv = -9;
				verifySettings(1.4, 30, 50);
			});
		});
		
		describe(@"When there are existing, compatible selections", ^{
			it(@"should keep a single selection", ^{
				selectShutterSpeed(8);
				calculator.thirdsLv = -9;
				verifySettings(1.4, 8, 200);
			});
			
			it(@"should keep both selections", ^{
				selectShutterSpeed(30);
				selectSensitivity(100);
				calculator.thirdsLv = -9;
				verifySettings(2, 30, 100);
			});
		});
		
		describe(@"When some existing selections are incompatible", ^{
			it(@"should discard a single incompatible selection", ^{
				selectShutterSpeed(6);
				calculator.thirdsLv = -24;
				verifySettings(1.4, 960, 50);
			});
			
			it(@"should keep the most recent setting if it's compatible", ^{
				// This test depends on the configured max ISO
				expect([[[SupportedSettings alloc] init].sensitivities lastObject]).to(equal(@6400));
				selectAperture(2.8);
				selectShutterSpeed(6);
				calculator.thirdsLv = 3 * -6.7;
				// We can reach -6.7 with either f/2.8 or 6s, but not both.
				// Since the shutter speed was selected most recently, we drop the aperture.
				verifySettings(1.4, 6, 3200);
			});
			
			it(@"should keep a compatible older selection if the most recent is incompatible", ^{
				// This test depends on our configured longest shutter speed.
				NSNumber *minShutter = @1920;
				expect([[SupportedSettings alloc] init].shutterSpeeds[0]).to(equal(minShutter));
				selectAperture(2.8);
				selectShutterSpeed(6);
				calculator.thirdsLv = 3 * -8;
				// We can't get to Lv -8 at 6s, so that setting gets dropped
				// even though it was the most recently specified.
				verifySettings(2.8, [minShutter doubleValue], 100);
			});
		});
	});
	
	describe(@"Responding to selections", ^{
		it(@"should discard a previous selection of the same control", ^{
			calculator.thirdsLv = 21;
			selectShutterSpeed(1.0/40.0);
			selectShutterSpeed(1.0/30.0);
			verifySettings(1.4, 1.0/30.0, 50);
			
			// Now set the shutter again after the aperture else in between.
			// We should keep the latest shutter speed as well as the aperture.
			selectAperture(2);
			selectShutterSpeed(1.0/60);
			verifySettings(2, 1.0/60.0, 200);
		});

	});
});

SPEC_END

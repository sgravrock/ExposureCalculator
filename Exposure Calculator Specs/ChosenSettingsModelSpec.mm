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
		calculator = [[Calculator alloc] initWithSettings:[SupportedSettings defaultSettings]];
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
				calculator.lv = -9;
				verifySettings(1.4, 30, 50);
			});
		});
		
		describe(@"When there are existing, compatible selections", ^{
			it(@"should keep a single selection", ^{
				selectShutterSpeed(8);
				calculator.lv = -9;
				verifySettings(1.4, 8, 200);
			});
			
			it(@"should keep both selections", ^{
				selectShutterSpeed(30);
				selectSensitivity(100);
				calculator.lv = -9;
				verifySettings(2, 30, 100);
			});
		});
		
		describe(@"When some existing selections are incompatible", ^{
			it(@"should discard a single incompatible selection", ^{
				selectShutterSpeed(6);
				calculator.lv = -24;
				verifySettings(1.4, 960, 50);
			});
			
			it(@"should keep a compatible selection", ^{
				// This test depends on our configured longest shutter speed.
				NSNumber *minShutter = @1920;
				expect([SupportedSettings defaultSettings].shutterSpeeds[0]).to(equal(minShutter));
				selectAperture(2.8);
				selectShutterSpeed(6);
				calculator.lv = -21;
				// We can't get to Lv -7 at 6s, so that setting gets dropped
				// even though it was the most recently specified.
				verifySettings(2.8, [minShutter doubleValue], 50);
			});
		});
	});
});

SPEC_END

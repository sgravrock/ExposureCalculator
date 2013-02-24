#import "ChosenSettingsModel.h"
#import "ConstrainedSettingsDataSource.h"
#import "cedar.h"
#import "Calculator.h"
#import "SupportedSettings.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ChosenSettingsModelSpec)

describe(@"ChosenSettingsModel", ^{
	__block ChosenSettingsModel *target;
	__block Calculator *calculator;
	__block id<CedarDouble, ChosenSettingsModelDelegate> delegate;
	
	void (^verifySettings)(int, int, int) = ^(int a, int s, int i) {
		expect(delegate).to(have_received(@selector(chosenSettingsModel:changedApertureToIndex:)).with(target).and_with(a));
		expect(delegate).to(have_received(@selector(chosenSettingsModel:changedShutterToIndex:)).with(target).and_with(s));
		expect(delegate).to(have_received(@selector(chosenSettingsModel:changedSensitivityToIndex:)).with(target).and_with(i));
	};
	
	void (^selectAperture)(NSNumber *) = ^(NSNumber *aperture) {
		int i = [target.dataSource.components[0] indexOfObject:aperture];
		NSAssert(i != NSNotFound, @"Couldn't find aperture");
		[target selectAperture:i];
	};
	
	void (^selectShutterSpeed)(NSNumber *) = ^(NSNumber *shutter) {
		int i = [target.dataSource.components[1] indexOfObject:shutter];
		NSAssert(i != NSNotFound, @"Couldn't find shutter speed");
		[target selectShutter:i];
	};
	
	void (^selectSensitivity)(NSNumber *) = ^(NSNumber *iso) {
		int i = [target.dataSource.components[2] indexOfObject:iso];
		NSAssert(i != NSNotFound, @"Couldn't find sensitivity");
		[target selectSensitivity:i];
	};
	
	beforeEach(^{
		calculator = [[Calculator alloc] initWithSettings:[SupportedSettings defaultSettings]];
		target = [[ChosenSettingsModel alloc] initWithCalculator:calculator];
		delegate = nice_fake_for(@protocol(ChosenSettingsModelDelegate));
		target.delegate = delegate;
	});
	
	afterEach(^{
		target = nil;
	});
	
	describe(@"Responding to Lv changes", ^{
		describe(@"When there are no existing selections", ^{
			it(@"should select the first compatible settings", ^{
				calculator.lv = -9;
				// Settings should be f/1.4, 30s, ISO 50
				int apertureIx = 0;
				int shutterIx = [target.dataSource.components[1] indexOfObject:@30];
				int isoIx = [target.dataSource.components[2] indexOfObject:@50];
				verifySettings(apertureIx, shutterIx, isoIx);
			});
		});
		
		describe(@"When there are existing, compatible selections", ^{
			it(@"should keep a single selection", ^{
				selectShutterSpeed(@8);
				[delegate reset_sent_messages];
				calculator.lv = -9;
				// Settings should be f/1.4, 8s, ISO 200
				int apertureIx = 0;
				int shutterIx = [target.dataSource.components[1] indexOfObject:@8];
				int isoIx = [target.dataSource.components[2] indexOfObject:@200];
				verifySettings(apertureIx, shutterIx, isoIx);
			});
			
			it(@"should keep both selections", ^{
				selectShutterSpeed(@30);
				selectSensitivity(@100);
				[delegate reset_sent_messages];
				calculator.lv = -9;
				// Settings should be f/2, 30s, ISO 100
				int apertureIx = [target.dataSource.components[0] indexOfObject:@2];
				int shutterIx = [target.dataSource.components[1] indexOfObject:@30];
				int isoIx = [target.dataSource.components[2] indexOfObject:@100];
				verifySettings(apertureIx, shutterIx, isoIx);
			});
		});
		
		describe(@"When some existing selections are incompatible", ^{
			it(@"should discard a single incompatible selection", ^{
				selectShutterSpeed(@6);
				[delegate reset_sent_messages];
				calculator.lv = -24;
				// Settings should be f/1.4, 960s, ISO 50
				int apertureIx = [target.dataSource.components[0] indexOfObject:@1.4];
				int shutterIx = [target.dataSource.components[1] indexOfObject:@960];
				int isoIx = [target.dataSource.components[2] indexOfObject:@50];
				verifySettings(apertureIx, shutterIx, isoIx);
			});
			
			it(@"should keep a compatible selection", ^{
				// This test depends on our configured longest shutter speed.
				NSNumber *minShutter = @1920;
				expect([SupportedSettings defaultSettings].shutterSpeeds[0]).to(equal(minShutter));
				selectAperture(@2.8);
				selectShutterSpeed(@6);
				[delegate reset_sent_messages];
				calculator.lv = -21;
				// We can't get to Lv -7 at 6s, so that setting gets dropped
				// even though it was the most recently specified.
				// Settings should be f/2.8, 1920s, ISO 50
				int apertureIx = [target.dataSource.components[0] indexOfObject:@2.8];
				int shutterIx = [target.dataSource.components[1] indexOfObject:minShutter];
				int isoIx = [target.dataSource.components[2] indexOfObject:@50];
				verifySettings(apertureIx, shutterIx, isoIx);
			});
		});
	});
});

SPEC_END

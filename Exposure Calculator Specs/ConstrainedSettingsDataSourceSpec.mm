#import "ConstrainedSettingsDataSource.h"
#import "Calculator.h"
#import "SupportedSettings.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ConstrainedSettingsDataSourceSpec)

describe(@"ConstrainedSettingsDataSource", ^{
	it(@"should only offer settings that are possible with the given constraints", ^{
		NSArray *supportedApertures = @[@4.0, @4.5, @5.0, @5.6];
		NSArray *supportedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60.0],
		[NSNumber numberWithDouble:1.0/80.0],
		[NSNumber numberWithDouble:1.0/100.0]];
		NSArray *supportedIsos = @[@100, @125, @160];
		
		SupportedSettings *config = [[SupportedSettings alloc] initWithApertures:supportedApertures
																   shutterSpeeds:supportedShutterSpeeds
																   sensitivities:supportedIsos];
		Calculator *calculator = [[Calculator alloc] initWithSettings:config];
		ConstrainedSettingsDataSource *target = [[ConstrainedSettingsDataSource alloc]
												 initWithCalculator:calculator];
		
		// After setting an Lv, only the settings that give that Lv should be available
		calculator.thirdsLv = [Calculator thirdsLvForAperture:4.0 shutter:1.0/60.0 sensitivity:125];
		[target update];
		NSArray *expectedApertures = @[@4.0, @4.5];
		NSArray *expectedShutterSpeeds = @[[NSNumber numberWithDouble:1.0/60], [NSNumber numberWithDouble:1.0/80]];
		NSArray *expectedIsos = @[@125, @160];
		expect(target.components[0]).to(equal(expectedApertures));
		expect(target.components[1]).to(equal(expectedShutterSpeeds));
		expect(target.components[2]).to(equal(expectedIsos));		
	});
});

SPEC_END

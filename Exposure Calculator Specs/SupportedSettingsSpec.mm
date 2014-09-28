#import "SupportedSettings.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupportedSettingsSpec)

describe(@"SupportedSettings", ^{
	__block SupportedSettings *target;
	
	void (^verifyApertures)(NSNumber *, NSNumber *) = ^(NSNumber *max, NSNumber *min) {
		expect(target.components[kApertureComponent][0]).to(equal(max));
		expect([target.components[kApertureComponent] lastObject]).to(equal(min));
	};
	
	void (^verifyShutterSpeeds)(NSNumber *, NSNumber *) = ^(NSNumber *min, NSNumber *max) {
		expect(target.components[kShutterComponent][0]).to(equal(min));
		expect([target.components[kShutterComponent] lastObject]).to(equal(max));
	};
	
	void (^verifyIsos)(NSNumber *, NSNumber *) = ^(NSNumber *min, NSNumber *max) {
		expect(target.components[kSensitivityComponent][0]).to(equal(min));
		expect([target.components[kSensitivityComponent] lastObject]).to(equal(max));
	};
	
	beforeEach(^{
		target = [[SupportedSettings alloc] init];
	});
	
	it(@"should default to the full range of settings", ^{
		verifyApertures(@1.4, @22);
		verifyShutterSpeeds(@(32 * 60), @(1.0 / 800.0));
		verifyIsos(@50, @6400);
	});
	
	it(@"should limit apertures to the specified range", ^{
		[target includeValuesFrom:@3.5 to:@16 inComponent:kApertureComponent];
		verifyApertures(@3.5, @16);
		[target includeValuesFrom:@16 to:@4 inComponent:kApertureComponent];
		verifyApertures(@4, @16);
	});
	
	it(@"should limit shutter speeds to the spedified range", ^{
		[target includeValuesFrom:@30 to:@(1.0 / 30.0) inComponent:kShutterComponent];
		verifyShutterSpeeds(@30, @(1.0 / 30.0));
	});

	it(@"should limit sensitivity to the spedified range", ^{
		[target includeValuesFrom:@100 to:@800 inComponent:kSensitivityComponent];
		verifyIsos(@100, @800);
	});
});

SPEC_END

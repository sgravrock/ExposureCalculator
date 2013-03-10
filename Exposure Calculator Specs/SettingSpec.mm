#import "Setting.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SettingSpec)

describe(@"Setting", ^{
	describe(@"Formatting shutter speeds", ^{
		void (^verify)(NSNumber *, NSString *) = ^(NSNumber *speed, NSString *expected) {
			expect([Setting formatSettingWithComponent:1 value:speed]).to(equal(expected));
		};
		
		it(@"should display a speed <1 second as a fraction", ^{
			verify(@(1.0/100.0), @"1/100");
		});
		
		it(@"should display speeds between 1 and 10 seconds with up to one decimal point", ^{
			verify(@1, @"1");
			verify(@1.3, @"1.3");
			verify(@1.6, @"1.6");
			verify(@10, @"10");
		});
		
		it(@"should display speeds between 10 and 59 seconds as whole seconds", ^{
			verify(@1, @"1");
			verify(@59, @"59");
			verify(@37.79763149684619, @"38");
		});

		it(@"should display whole minutes as whole minutes", ^{
			verify(@60, @"1m");
			verify(@(60 * 32), @"32m");
		});
		
		it(@"should display fractional minutes >1 as minutes and seconds", ^{
			verify(@75.59526299369239, @"1m16s");
			verify(@151.1905259873848, @"2m31s");
		});
	});
});

SPEC_END

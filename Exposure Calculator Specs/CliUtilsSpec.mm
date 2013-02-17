#import "CliUtils.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CliUtilsSpec)

describe(@"CliUtils", ^{
	describe(@"shutterFromString:", ^{
		it(@"should convert the string to the corresponding shutter speed", ^{
			expect([CliUtils shutterFromString:"1/500"]).to(equal([NSNumber numberWithDouble:1.0/500.0]));
			expect([CliUtils shutterFromString:"8"]).to(equal(@8.0));
		});
		
		it(@"should return nil if the string isn't a valid shutter speed", ^{
			expect([CliUtils shutterFromString:"1/foo"]).to(be_nil());
			expect([CliUtils shutterFromString:"foo"]).to(be_nil());
		});
	});
	
	describe(@"apertureFromString:", ^{
		it(@"should accept apertures prefixed with f/", ^{
			expect([CliUtils apertureFromString:"f/2.8"]).to(equal(@2.8));
			expect([CliUtils apertureFromString:"f/4"]).to(equal(@4));
		});
		
		it(@"should accept apertures not prefixed with f/", ^{
			expect([CliUtils apertureFromString:"2.8"]).to(equal(@2.8));
			expect([CliUtils apertureFromString:"4"]).to(equal(@4));
		});
		
		it(@"should return nil if the string isn't an aperture", ^{
			expect([CliUtils apertureFromString:"f/oo"]).to(be_nil());
		});
	});
	
	describe(@"intFromString:", ^{
		it(@"should accept a valid integer", ^{
			expect([CliUtils intFromString:"1600"]).to(equal(@1600));
		});
		
		it(@"should return nil if the string isn't a valid integer", ^{
			expect([CliUtils intFromString:"foo"]).to(be_nil());
		});
	});
});

SPEC_END

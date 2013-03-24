#import "MinMaxPair.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MinMaxPairSpec)

describe(@"MinMaxPair", ^{
    __block MinMaxPair *target;

    beforeEach(^{
		target = [[MinMaxPair alloc] initWithMin:0 max:3];
    });
	
	it(@"should default to the entire range of possible settings", ^{
		expect(target.min).to(equal(0));
		expect(target.max).to(equal(3));
	});
	
	it(@"should update min when max is set to something less", ^{
		target.min = 2;
		target.max = 1;
		expect(target.min).to(equal(1));
	});

	it(@"should update max when min is set to something greater", ^{
		target.max = 2;
		target.min = 3;
		expect(target.max).to(equal(3));
	});
});

SPEC_END

#import "FakeProperties.h"
#import "cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FakePropertiesSpec)

describe(@"FakeProperties", ^{
	__block UIPickerView *target;
	
	beforeEach(^{
		id<CedarDouble> fake = [fake_for([UIPickerView class]) retain];
		target = (UIPickerView *)fake;
		[FakeProperties stubProperty:"delegate" onObject:fake];
	});
	
	afterEach(^{
		[target release];
		target = nil;
	});
	
	describe(@"stubProperty", ^{
		it(@"sets the initial property value to nil", ^{
			expect(target.delegate).to(be_nil());
		});
		
		it(@"sets the property value to the specified value", ^{
			id<UIPickerViewDelegate> value = nice_fake_for(@protocol(UIPickerViewDelegate));
			target.delegate = value;
			expect(target.delegate).to(be_same_instance_as(value));
		});
	});
});

SPEC_END

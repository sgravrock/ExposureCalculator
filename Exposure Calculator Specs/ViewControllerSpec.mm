#import "ViewController.h"
#import "FakeProperties.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
    __block ViewController *target;
	__block id<CedarDouble> chosenSettingsPicker;

    beforeEach(^{
		target = [[ViewController alloc] init];
		chosenSettingsPicker = nice_fake_for([UIPickerView class]);
		[FakeProperties stubProperty:"dataSource" onObject:chosenSettingsPicker];
		target.chosenSettingsPicker = (UIPickerView *)chosenSettingsPicker;
		[target viewDidLoad];
    });
	
	afterEach(^{
		[target release];
		target = nil;
		chosenSettingsPicker = nil;
	});
	
	it(@"Should preserve selections when a setting is unlocked", ^{
		[target pickerView:target.chosenSettingsPicker didSelectRow:6 inComponent:0];
		
		// Make sure we've selected the aperture we thought we did, and locked it
		__block int selected = [target.chosenSettingsPicker selectedRowInComponent:0];
		NSString *title = [target pickerView:target.chosenSettingsPicker
								 titleForRow:selected
								forComponent:0];
		expect(title).to(equal(@"f/2.8"));
		int rows = [target.chosenSettingsPicker.dataSource pickerView:target.chosenSettingsPicker
											  numberOfRowsInComponent:0];
		expect(rows).to(equal(1));
		
		// Unlock the aperture.
		chosenSettingsPicker stub_method("selectRow:inComponent:animated:").and_do(^(NSInvocation *invocation) {
			int row, component;
			[invocation getArgument:&component atIndex:3];
			
			if (component == 0) {
				[invocation getArgument:&row atIndex:2];
				selected = row;
			}
		});
		
		[target unlockAperture:nil];
		
		// There should be more than one row, and the previous aperture should still be selected.
		rows = [target.chosenSettingsPicker.dataSource pickerView:target.chosenSettingsPicker
										  numberOfRowsInComponent:0];
		expect(rows).to(be_greater_than(6));
		expect(chosenSettingsPicker).to(have_received("selectRow:inComponent:animated:"));
		title = [target pickerView:target.chosenSettingsPicker titleForRow:selected forComponent:0];
		expect(title).to(equal(@"f/2.8"));
	});
});

SPEC_END

#import "MainViewController.h"
#import "cedar.h"
#import "JRSwizzle.h"
#import "SupportedSettings.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MainViewController(ViewControllerSpecSupport)
- (void)fakeDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end

@implementation MainViewController(ViewControllerSpecSupport)
- (void)fakeDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
	completion();
}
@end

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
	__block MainViewController *target;
	__block UIPickerView<CedarDouble> *meteredSettingsPicker;
	__block BOOL swapped = NO;

	beforeEach(^{
		NSError *error;
		swapped = [MainViewController jr_swizzleMethod:@selector(dismissViewControllerAnimated:completion:)
											withMethod:@selector(fakeDismissViewControllerAnimated:completion:)
												 error:&error];
		
		if (!swapped) {
			@throw [NSException exceptionWithName:@"Swizzle failed"
										   reason:[error localizedDescription]
										 userInfo:nil];
		}
		
		target = [[MainViewController alloc] init];
		target.meteredSettingsPicker = meteredSettingsPicker = nice_fake_for([UIPickerView class]);
		[target viewDidLoad];
		
		// Select a known row in each component
		for (int i = 0; i < 3; i++) {
			[target pickerView:meteredSettingsPicker didSelectRow:4 inComponent:i];
		}
		
		[meteredSettingsPicker reset_sent_messages];
	});
	
	afterEach(^{
		target = nil;
		meteredSettingsPicker = nil;
		
		if (swapped) {
			[MainViewController jr_swizzleMethod:@selector(dismissViewControllerAnimated:completion:)
									  withMethod:@selector(fakeDismissViewControllerAnimated:completion:)
										   error:nil];
		}
	});
	
	describe(@"When the configuration changes", ^{
		describe(@"When the current metered settings are below the new range", ^{
			it(@"should change to the first available setting", ^{
				[target.configuration includeValuesFrom:target.configuration.components[kApertureComponent][5]
													 to:[target.configuration.components[kApertureComponent] lastObject]
											inComponent:kApertureComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kShutterComponent][6]
													 to:[target.configuration.components[kShutterComponent] lastObject]
											inComponent:kShutterComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kShutterComponent][7]
													 to:[target.configuration.components[kShutterComponent] lastObject] 
											inComponent:kSensitivityComponent];
				
				[target configViewControllerShouldClose:nil];
				
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(0).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(1).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(2).and_with(NO));
			});
		});
		
		describe(@"When the current metered settings are above the new range", ^{
			it(@"should change to the first available setting", ^{
				[target.configuration includeValuesFrom:target.configuration.components[kApertureComponent][0]
													 to:target.configuration.components[kApertureComponent][1]
											inComponent:kApertureComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kShutterComponent][0]
													 to:target.configuration.components[kShutterComponent][2]
											inComponent:kShutterComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kSensitivityComponent][0]
													 to:target.configuration.components[kSensitivityComponent][3]
											inComponent:kSensitivityComponent];
				
				[target configViewControllerShouldClose:nil];
				
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(kApertureComponent).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(kShutterComponent).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(kSensitivityComponent).and_with(NO));
			});
		});

		describe(@"When the current metered settings are within the new range", ^{
			it(@"should not change any settings", ^{
				[target.configuration includeValuesFrom:target.configuration.components[kApertureComponent][1]
													 to:[target.configuration.components[kApertureComponent] lastObject]
											inComponent:kApertureComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kShutterComponent][2]
													 to:[target.configuration.components[kShutterComponent] lastObject]
											inComponent:kShutterComponent];
				[target.configuration includeValuesFrom:target.configuration.components[kSensitivityComponent][3]
													 to:[target.configuration.components[kSensitivityComponent] lastObject]
											inComponent:kSensitivityComponent];

				[target configViewControllerShouldClose:nil];
				
				// The same settings should be selected. But the set of valid settings changed, so
				// the selected settings will be at different indices.
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(3).and_with(0).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(2).and_with(1).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(1).and_with(2).and_with(NO));
			});
		});
	});
	
	it(@"should save and restore its configuration", ^{
		NSArray *apertures = target.configuration.components[0];
		NSNumber *minAperture = apertures[apertures.count - 3];
		NSNumber *maxAperture = [apertures lastObject];
		[target.configuration includeValuesFrom:minAperture to:maxAperture inComponent:kApertureComponent];
		[target configViewControllerShouldClose:nil];
		NSMutableData *data = [NSMutableData data];
		NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[target encodeRestorableStateWithCoder:encoder];
		[encoder finishEncoding];
		target = [[MainViewController alloc] init];
		target.meteredSettingsPicker = meteredSettingsPicker = nice_fake_for([UIPickerView class]);
		[target viewDidLoad];
		[meteredSettingsPicker reset_sent_messages];
		[target decodeRestorableStateWithCoder:[[NSKeyedUnarchiver alloc] initForReadingWithData:data]];
		
		expect(target.configuration.components[0][0]).to(equal(minAperture));
		expect([target.configuration.components[0] lastObject]).to(equal(maxAperture));
		expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
												.with(0).and_with(0).and_with(NO));
	});
});

SPEC_END

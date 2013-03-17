#import "ViewController.h"
#import "cedar.h"
#import "JRSwizzle.h"
#import "SupportedSettings.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ViewController(ViewControllerSpecSupport)
- (void)fakeDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end

@implementation ViewController(ViewControllerSpecSupport)
- (void)fakeDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
	completion();
}
@end

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
	__block ViewController *target;
	__block UIPickerView<CedarDouble> *meteredSettingsPicker;
	__block BOOL swapped = NO;

	beforeEach(^{
		NSError *error;
		swapped = [ViewController jr_swizzleMethod:@selector(dismissViewControllerAnimated:completion:)
										withMethod:@selector(fakeDismissViewControllerAnimated:completion:)
											 error:&error];
		
		if (!swapped) {
			@throw [NSException exceptionWithName:@"Swizzle failed"
										   reason:[error localizedDescription]
										 userInfo:nil];
		}
		
		target = [[ViewController alloc] init];
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
			[ViewController jr_swizzleMethod:@selector(dismissViewControllerAnimated:completion:)
								  withMethod:@selector(fakeDismissViewControllerAnimated:completion:)
									   error:nil];
		}
	});
	
	describe(@"When the configuration changes", ^{
		describe(@"When the current metered settings are below the new range", ^{
			it(@"should change to the first available setting", ^{
				[target.configuration includeAperturesFrom:target.configuration.apertures[5]
														to:[target.configuration.apertures lastObject]];
				[target.configuration includeShutterSpeedsFrom:target.configuration.shutterSpeeds[6]
															to:[target.configuration.shutterSpeeds lastObject]];
				[target.configuration includeSensitivitiesFrom:target.configuration.sensitivities[7]
															to:[target.configuration.sensitivities lastObject]];
				
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
				[target.configuration includeAperturesFrom:target.configuration.apertures[0]
														to:target.configuration.apertures[1]];
				[target.configuration includeShutterSpeedsFrom:target.configuration.shutterSpeeds[0]
															to:target.configuration.shutterSpeeds[2]];
				[target.configuration includeSensitivitiesFrom:target.configuration.sensitivities[0]
															to:target.configuration.sensitivities[3]];
				
				[target configViewControllerShouldClose:nil];
				
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(0).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(1).and_with(NO));
				expect(target.meteredSettingsPicker).to(have_received(@selector(selectRow:inComponent:animated:))
														.with(0).and_with(2).and_with(NO));
			});
		});

		describe(@"When the current metered settings are within the new range", ^{
			it(@"should not change any settings", ^{
				[target.configuration includeAperturesFrom:target.configuration.apertures[1]
														to:[target.configuration.apertures lastObject]];
				[target.configuration includeShutterSpeedsFrom:target.configuration.shutterSpeeds[2]
															to:[target.configuration.shutterSpeeds lastObject]];
				[target.configuration includeSensitivitiesFrom:target.configuration.sensitivities[3]
															to:[target.configuration.sensitivities lastObject]];

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
});

SPEC_END

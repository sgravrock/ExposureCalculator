#import "ChosenSettingsModel.h"
#import "ConstrainedSettingsDataSource.h"
#import "cedar.h"
#import "Calculator.h"
#import "SupportedSettings.h"
#import "StubChosenSettingsModelDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface CSMSpecContext: NSObject
@property (nonatomic, readonly, strong) ChosenSettingsModel *target;
@property (nonatomic, readonly, strong) Calculator *calculator;
@property (nonatomic, readonly, strong) StubChosenSettingsModelDelegate *delegate;

- (instancetype)initWithDefaults;
- (instancetype)initWithSettings:(SupportedSettings *)settings;
- (void)verifyAperture:(double)aperture shutter:(double)shutter sensitivity:(double)sensitivity;
- (void)selectAperture:(double)aperture;
- (void)selectShutterSpeed:(double)shutter;
- (void)selectSensitivity:(double)iso;
@end

@implementation CSMSpecContext

- (instancetype)initWithDefaults {
    return [self initWithSettings:[[SupportedSettings alloc] init]];
}
- (instancetype)initWithSettings:(SupportedSettings *)settings {
    if ((self = [super init])) {
        _calculator = [[Calculator alloc] initWithSettings:settings];
        _target = [[ChosenSettingsModel alloc] initWithCalculator:_calculator];
        _delegate = [[StubChosenSettingsModelDelegate alloc] init];
        _target.delegate = _delegate;
    }
    
    return self;
}

- (void)verifyAperture:(double)aperture shutter:(double)shutter sensitivity:(double)sensitivity {
    [self assertThatComopnent:kApertureComponent hasValue:@(aperture)];
    [self assertThatComopnent:kShutterComponent hasValue:@(shutter)];
    [self assertThatComopnent:kSensitivityComponent hasValue:@(sensitivity)];
}

- (void)assertThatComopnent:(int)component hasValue:(NSNumber *)expected {
    NSUInteger i = self.delegate->settings[component];
    NSNumber *actual = self.target.dataSource.components[component][i];
    expect(actual).to(equal(expected));
}

- (void)selectAperture:(double)aperture {
    NSUInteger i = [self.target.dataSource.components[kApertureComponent]
                    indexOfObject:[NSNumber numberWithDouble:aperture]];
    NSAssert(i != NSNotFound, @"Couldn't find aperture");
    [self.target selectIndex:i forComponent:kApertureComponent];
}

- (void)selectShutterSpeed:(double)shutter {
    NSUInteger i = [self.target.dataSource.components[kShutterComponent]
                    indexOfObject:[NSNumber numberWithDouble:shutter]];
    NSAssert(i != NSNotFound, @"Couldn't find shutter speed");
    [self.target selectIndex:i forComponent:kShutterComponent];
}

- (void)selectSensitivity:(double)iso {
    NSUInteger i = [self.target.dataSource.components[kSensitivityComponent]
                    indexOfObject:[NSNumber numberWithInt:iso]];
    NSAssert(i != NSNotFound, @"Couldn't find sensitivity");
    [self.target selectIndex:i forComponent:kSensitivityComponent];
}


@end

SPEC_BEGIN(ChosenSettingsModelSpec)

describe(@"ChosenSettingsModel", ^{
	describe(@"Responding to Lv changes", ^{
		describe(@"When there are no existing selections", ^{
			it(@"should select the first compatible settings", ^{
                SupportedSettings *settings = [[SupportedSettings alloc] init];
                [settings includeValuesFrom:@1.4 to:@22 inComponent:kApertureComponent];
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithSettings:settings];
				ctx.calculator.thirdsLv = -9;
                [ctx verifyAperture:1.4 shutter:30 sensitivity:50];
			});
		});
		
		describe(@"When there are existing, compatible selections", ^{
			it(@"should keep a single selection", ^{
                SupportedSettings *settings = [[SupportedSettings alloc] init];
                [settings includeValuesFrom:@1.4 to:@22 inComponent:kApertureComponent];
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithSettings:settings];
                [ctx selectShutterSpeed:8];
                ctx.calculator.thirdsLv = -9;
                [ctx verifyAperture:1.4 shutter:8 sensitivity:200];
			});
			
			it(@"should keep both selections", ^{
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithDefaults];
                [ctx selectShutterSpeed:30];
                [ctx selectSensitivity:100];
				ctx.calculator.thirdsLv = -9;
                [ctx verifyAperture:2 shutter:30 sensitivity:100];
			});
		});
		
		describe(@"When some existing selections are incompatible", ^{
			it(@"should discard a single incompatible selection", ^{
                SupportedSettings *settings = [[SupportedSettings alloc] init];
                [settings includeValuesFrom:@1.4 to:@22 inComponent:kApertureComponent];
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithSettings:settings];
                [ctx selectShutterSpeed:6];
				ctx.calculator.thirdsLv = -24;
                [ctx verifyAperture:1.4 shutter:960 sensitivity:50];
			});
			
			it(@"should keep the most recent setting if it's compatible", ^{
                SupportedSettings *settings = [[SupportedSettings alloc] init];
                [settings includeValuesFrom:@1.4 to:@22 inComponent:kApertureComponent];
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithSettings:settings];
                [ctx selectSensitivity:6400];
                [ctx selectAperture:2.8];
                [ctx selectShutterSpeed:6];
                
				ctx.calculator.thirdsLv = 3 * -6.7;
				// We can reach -6.7 with either f/2.8 or 6s, but not both.
				// Since the shutter speed was selected most recently, we drop the aperture.
                [ctx verifyAperture:1.4 shutter:6 sensitivity:3200];
			});
			
			it(@"should keep a compatible older selection if the most recent is incompatible", ^{
                SupportedSettings *settings = [[SupportedSettings alloc] init];
                [settings includeValuesFrom:@1.4 to:@22 inComponent:kApertureComponent];
                CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithSettings:settings];
				// This test depends on our configured longest shutter speed.
				NSNumber *minShutter = @1920;
				expect([[SupportedSettings alloc] init].components[kShutterComponent][0]).to(equal(minShutter));
                [ctx selectAperture:2.8];
                [ctx selectShutterSpeed:5];
				ctx.calculator.thirdsLv = 3 * -8;
				// We can't get to Lv -8 at 6s, so that setting gets dropped
				// even though it was the most recently specified.
                [ctx verifyAperture:2.8 shutter:[minShutter doubleValue] sensitivity:100];\
			});
		});
	});
	
	describe(@"Responding to selections", ^{
		it(@"should discard a previous selection of the same control", ^{
            CSMSpecContext *ctx = [[CSMSpecContext alloc] initWithDefaults];
			ctx.calculator.thirdsLv = 21;
            [ctx selectShutterSpeed:1.0/40.0];
            [ctx selectShutterSpeed:1.0/30.0];
            [ctx verifyAperture:1.4 shutter:1.0/30.0 sensitivity:50];
			
			// Now set the shutter again after the aperture else in between.
			// We should keep the latest shutter speed as well as the aperture.
            [ctx selectAperture:2];
            [ctx selectShutterSpeed:1.0/60.0];
            [ctx verifyAperture:2 shutter:1.0/60.0 sensitivity:200];
		});
	});
});

SPEC_END

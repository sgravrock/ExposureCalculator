//
//  ChosenSettingsModel.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/23/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ChosenSettingsModel.h"
#import "ConstrainedSettingsDataSource.h"
#import "Calculator.h"
#import "Setting.h"

static void * const kvo_context = (void * const)&kvo_context;

@interface ChosenSettingsModel()
@property (nonatomic, strong) Setting *firstChoice;
@property (nonatomic, strong) Setting *secondChoice;
@property (nonatomic, strong) Calculator *calculator;
@property (nonatomic, strong) ConstrainedSettingsDataSource *dataSource;
@end

@implementation ChosenSettingsModel

- (id)initWithCalculator:(Calculator *)calculator
{
	self = [super init];
	
	if (self) {
		self.calculator = calculator;
		self.dataSource = [[ConstrainedSettingsDataSource alloc] initWithCalculator:calculator];
		// Subscribe to changes in the calculated Lv
		[calculator addObserver:self
					 forKeyPath:@"thirdsLv"
						options:NSKeyValueObservingOptionNew
						context:kvo_context];
	}

	return self;
}

- (void)dealloc
{
	[self.calculator removeObserver:self forKeyPath:@"thirdsLv" context:kvo_context];
}

- (void)selectAperture:(int)index
{
	[self addChoice:index forComponent:0];
}

- (void)selectShutter:(int)index
{
	[self addChoice:index forComponent:1];
}

- (void)selectSensitivity:(int)index
{
	[self addChoice:index forComponent:2];
}

- (void)addChoice:(int)index forComponent:(int)component
{
	NSNumber *value = self.dataSource.components[component][index];
	Setting *setting = [Setting settingWithComponent:component value:value];

	if (self.firstChoice && self.firstChoice.component == component) {
		self.firstChoice = setting;
	} else {
		self.secondChoice = self.firstChoice;
		self.firstChoice = setting;
	}
	
	[self updateSettings];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	[self.dataSource update];
	[self updateSettings];
}

- (void)updateSettings
{
	NSDictionary *settings = [self.calculator.validSettings objectAtIndex:[self findSettings]];
	
	int apertureIx = [self.dataSource.components[0] indexOfObject:settings[@"aperture"]];
	int shutterIx = [self.dataSource.components[1] indexOfObject:settings[@"shutterSpeed"]];
	int isoIx = [self.dataSource.components[2] indexOfObject:settings[@"sensitivity"]];
	NSAssert(apertureIx != NSNotFound, @"Aperture index not found");
	NSAssert(shutterIx != NSNotFound, @"Shutter index not found");
	NSAssert(isoIx != NSNotFound, @"ISO index not found");
	[self.delegate chosenSettingsModel:self changedApertureToIndex:apertureIx];
	[self.delegate chosenSettingsModel:self changedShutterToIndex:shutterIx];
	[self.delegate chosenSettingsModel:self changedSensitivityToIndex:isoIx];
}

- (int)findSettings
{
	// Try to find valid settings, preferring the user's more recent choice if any.
	int scenarios[][2] = {{0, 1}, {0, -1}, {1, -1}, {-1, -1}};
	
	for (int i = 0; i < 4; i++) {
		int *s = scenarios[i];
		Setting *a = s[0] == 0 ? self.firstChoice : (s[0] == 1 ? self.secondChoice : nil);
		Setting *b = s[1] == 0 ? self.firstChoice : (s[1] == 1 ? self.secondChoice : nil);
		int result = [self indexOfFirstSettingsMatchingChoice:a andChoice:b];
		
		if (result != NSNotFound) {
			return result;
		}
	}
	
	// Can't happen
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"Couldn't find any valid setting" userInfo:nil];
}

// Either argument may be nil.
- (int)indexOfFirstSettingsMatchingChoice:(Setting *)choice1
								andChoice:(Setting *)choice2
{
	return [self.calculator.validSettings indexOfObjectPassingTest:
			 ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				return [self settings:obj matchUserChoice:choice1]
				 && [self settings:obj matchUserChoice:choice2];
			 }];
}

- (BOOL)settings:(NSDictionary *)settings matchUserChoice:(Setting *)choice
{
	static NSArray *componentKeys = nil;
	
	if (!componentKeys) {
		componentKeys = @[@"aperture", @"shutterSpeed", @"sensitivity"];
	}
	
	BOOL result = !choice || [settings[componentKeys[choice.component]] isEqual:choice.value];
	return result;
}

@end



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

- (void)selectIndex:(NSUInteger)index forComponent:(NSUInteger)component
{
	NSNumber *value = self.dataSource.components[component][index];
	Setting *setting = [Setting settingWithComponent:component value:value];

	if (self.firstChoice && self.firstChoice.component == component) {
		self.firstChoice = setting;
	} else {
		self.secondChoice = self.firstChoice;
		self.firstChoice = setting;
	}
	
	[self update];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	[self update];
}

- (void)update
{
	[self.dataSource update];
	NSArray<NSNumber *> *settings = [self.calculator.validSettings objectAtIndex:[self findSettings]];
	
	for (int i = 0; i < 3; i++) {
		NSUInteger settingIx = [self.dataSource.components[i] indexOfObject:settings[i]];
		NSAssert(settingIx != NSNotFound, @"Setting index not found");
		[self.delegate chosenSettingsModel:self changedComponent:i toIndex:settingIx];
	}
}

- (NSUInteger)findSettings
{
	// Try to find valid settings, preferring the user's more recent choice if any.
	int scenarios[][2] = {{0, 1}, {0, -1}, {1, -1}, {-1, -1}};
	
	for (int i = 0; i < 4; i++) {
		int *s = scenarios[i];
		Setting *a = s[0] == 0 ? self.firstChoice : (s[0] == 1 ? self.secondChoice : nil);
		Setting *b = s[1] == 0 ? self.firstChoice : (s[1] == 1 ? self.secondChoice : nil);
		NSUInteger result = [self indexOfFirstSettingsMatchingChoice:a andChoice:b];
		
		if (result != NSNotFound) {
			return result;
		}
	}
	
	// Can't happen
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"Couldn't find any valid setting" userInfo:nil];
}

// Either argument may be nil.
- (NSUInteger)indexOfFirstSettingsMatchingChoice:(Setting *)choice1
								andChoice:(Setting *)choice2
{
	return [self.calculator.validSettings indexOfObjectPassingTest:
			 ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
				return [self settings:obj matchUserChoice:choice1]
				 && [self settings:obj matchUserChoice:choice2];
			 }];
}

- (BOOL)settings:(NSArray *)settings matchUserChoice:(Setting *)choice
{
	BOOL result = !choice || [settings[choice.component] isEqual:choice.value];
	return result;
}

@end



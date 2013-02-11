//
//  ConstrainedSettingsDataSource.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ConstrainedSettingsDataSource.h"
#import "Calculator.h"

@interface ConstrainedSettingsDataSource()
@property (nonatomic, strong) Calculator *calculator;
@end

@implementation ConstrainedSettingsDataSource

- (id)initWithCalculator:(Calculator *)calculator
{
	self = [super init];
	
	if (self) {
		self.calculator = calculator;
		[self update];
	}
	
	return self;
}

- (void)update
{
	NSMutableSet *apertures = [NSMutableSet set];
	NSMutableSet *shutterSpeeds = [NSMutableSet set];
	NSMutableSet *isos = [NSMutableSet set];
	
	for (NSDictionary *setting in [self.calculator validSettings]) {
		[apertures addObject:setting[@"aperture"]];
		[shutterSpeeds addObject:setting[@"shutterSpeed"]];
		[isos addObject:setting[@"sensitivity"]];
	}
	
	self.components = @[[self sortedArrayFromSet:apertures ascending:YES],
		[self sortedArrayFromSet:shutterSpeeds ascending:NO],
		[self sortedArrayFromSet:isos ascending:YES]];
}

- (NSArray *)sortedArrayFromSet:(NSSet *)set ascending:(BOOL)ascending
{
	NSSortDescriptor *d = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:ascending];
	return [set sortedArrayUsingDescriptors:@[d]];
}

@end

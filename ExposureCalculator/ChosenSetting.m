//
//  ChosenSetting.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/24/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ChosenSetting.h"

@interface ChosenSetting()
@property (nonatomic, assign) int component;
@property (nonatomic, strong) NSNumber *value;
@end

@implementation ChosenSetting

+ (ChosenSetting *)settingWithComponent:(int)component value:(NSNumber *)value
{
	ChosenSetting *s = [[ChosenSetting alloc] init];
	s.component = component;
	s.value = value;
	return s;
}

@end

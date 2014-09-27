//
//  FakeProperties.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "FakeProperties.h"
#import <string.h>
#import <ctype.h>
#import <Cedar-iOS/Cedar-iOS.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@implementation FakeProperties

+ (void)stubProperty:(const char *)propName onObject:(id<CedarDouble>)target
{
	__block id propertyValue = nil;
	int len = strlen(propName) + 5; // "set"/"get", ":", terminator
	char setter[len];
	snprintf(setter, len, "set%c%s:", toupper(propName[0]), propName + 1);
	
	target stub_method(setter).and_do(^(NSInvocation *invocation) {
		__unsafe_unretained id temp;
		[invocation getArgument:&temp atIndex:2];
		propertyValue = temp;
	});
	
	target stub_method(propName).and_do(^(NSInvocation *invocation) {
		[invocation setReturnValue:&propertyValue];
	});
}

@end

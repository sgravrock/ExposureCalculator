//
//  ViewController_test.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ViewController.h"

@interface ViewController_test : SenTestCase
@end

@implementation ViewController_test

- (void)testCanDoStuff {
	ViewController *target = [[ViewController alloc] init];
	[target pickerView:target.chosenSettingsPicker didSelectRow:5 inComponent:0];
}

@end

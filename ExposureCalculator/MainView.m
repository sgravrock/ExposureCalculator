//
//  MainView.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/30/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "MainView.h"

@implementation MainView

- (void)layoutSubviews {
	CGRect childFrame = self.pickerContainer.frame;
	childFrame.origin.x = (self.bounds.size.width - childFrame.size.width) / 2;
	self.pickerContainer.frame = childFrame;
}

@end

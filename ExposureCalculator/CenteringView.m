//
//  MainView.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/30/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "CenteringView.h"

@implementation CenteringView

- (void)layoutSubviews {
	CGRect childFrame = self.subviewToCenter.frame;
	childFrame.origin.x = (self.bounds.size.width - childFrame.size.width) / 2;
	self.subviewToCenter.frame = childFrame;
}

@end

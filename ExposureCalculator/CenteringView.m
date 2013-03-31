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
	CGFloat width = self.bounds.size.width;
	CGRect childFrame = self.subviewToCenter.frame;
	childFrame.origin.x = (width - childFrame.size.width) / 2;
	self.subviewToCenter.frame = childFrame;
	
	childFrame = self.subviewToFillWidth.frame;
	childFrame.size.width = width;
	self.subviewToFillWidth.frame = childFrame;
}

@end

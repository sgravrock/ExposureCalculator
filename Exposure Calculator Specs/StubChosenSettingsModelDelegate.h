//
//  StubChosenSettingsModelDelegate.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChosenSettingsModel.h"

@interface StubChosenSettingsModelDelegate : NSObject<ChosenSettingsModelDelegate> {
@public
	// Each element exposes the last index received from the model for that component.
	// Intiial value for each is -1.
	int settings[3];
}

@end

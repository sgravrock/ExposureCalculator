//
//  StubChosenSettingsModelDelegate.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChosenSettingsModel.h"

@interface StubChosenSettingsModelDelegate : NSObject<ChosenSettingsModelDelegate>

// Each property exposes the last index received from the model for that component.
// Intiial value for each is -1.
@property (nonatomic, assign) int apertureIx;
@property (nonatomic, assign) int shutterSpeedIx;
@property (nonatomic, assign) int sensitivityIx;

@end

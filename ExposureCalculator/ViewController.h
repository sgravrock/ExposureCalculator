//
//  ViewController.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIPickerView *meteredSettingsPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *chosenSettingsPicker;

- (IBAction)unlockAperture:(id)ignored;
- (IBAction)unlockShutter:(id)ignored;
- (IBAction)unlockSensitivity:(id)ignored;

@end

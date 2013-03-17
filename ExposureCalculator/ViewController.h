//
//  ViewController.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChosenSettingsModel.h"
#import "ConfigViewControllerDelegate.h"

@interface ViewController : UIViewController<UIPickerViewDelegate, ChosenSettingsModelDelegate,
	ConfigViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIPickerView *meteredSettingsPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *chosenSettingsPicker;

@end

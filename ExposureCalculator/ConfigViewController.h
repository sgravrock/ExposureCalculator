//
//  CofigurationViewController.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigViewControllerDelegate;
@class SupportedSettings;

@interface ConfigViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
	UIPickerViewDelegate>

@property (nonatomic, weak) id<ConfigViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

// Should be set by the caller.
@property (nonatomic, strong) SupportedSettings *configuration;

@end

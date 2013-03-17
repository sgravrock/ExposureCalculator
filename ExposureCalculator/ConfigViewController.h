//
//  CofigurationViewController.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigViewControllerDelegate;

@interface ConfigViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
	UIPickerViewDelegate>

@property (nonatomic, weak) id<ConfigViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

- (IBAction)close:(id)sender;

@end

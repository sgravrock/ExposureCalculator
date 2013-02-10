//
//  ViewController.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/8/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import "ViewController.h"
#import "SettingsDataSource.h"

@interface ViewController ()
@property (nonatomic, strong) SettingsDataSource *meteredSettings;
@property (nonatomic, strong) SettingsDataSource *chosenSettings;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.meteredSettings = [[SettingsDataSource alloc] init];
	self.meteredSettingsPicker.dataSource = self.meteredSettings;
	self.meteredSettingsPicker.delegate = self.meteredSettings;
	self.chosenSettings = [[SettingsDataSource alloc] init];
	self.chosenSettingsPicker.dataSource = self.chosenSettings;
	self.chosenSettingsPicker.delegate = self.chosenSettings;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

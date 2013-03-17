//
//  ConfigViewControllerDelegate.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 3/17/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SupportedSettings, ConfigViewController;

@protocol ConfigViewControllerDelegate <NSObject>
@property (nonatomic, strong) SupportedSettings *configuration;
- (void)configViewControllerShouldClose:(ConfigViewController *)sender;
@end

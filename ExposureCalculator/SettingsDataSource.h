//
//  SettingsDataSource.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/9/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsDataSource : NSObject<UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *apertures;
@property (nonatomic, strong) NSArray *shutterSpeeds;
@property (nonatomic, strong) NSArray *isos;


@end

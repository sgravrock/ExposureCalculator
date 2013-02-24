//
//  ChosenSettingsModel.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/23/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Calculator;
@class ConstrainedSettingsDataSource;
@protocol ChosenSettingsModelDelegate;

@interface ChosenSettingsModel : NSObject

@property (readonly, nonatomic, strong) ConstrainedSettingsDataSource *dataSource;
@property (nonatomic, weak) id<ChosenSettingsModelDelegate> delegate;

- (id)initWithCalculator:(Calculator *)calculator;
// All three select* methods take the index of the selected values, within the list of
// available values for the setting in question. 
- (void)selectAperture:(int)index;
- (void)selectShutter:(int)index;
- (void)selectSensitivity:(int)index;

@end


@protocol ChosenSettingsModelDelegate

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedApertureToIndex:(int)index;
- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedShutterToIndex:(int)index;
- (void)chosenSettingsModel:(ChosenSettingsModel *)sender changedSensitivityToIndex:(int)index;

@end
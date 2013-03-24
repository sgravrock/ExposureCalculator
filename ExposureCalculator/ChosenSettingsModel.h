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
- (void)update;

// Takes the index of the selected value in the list of available values for the setting in question. 
- (void)selectIndex:(int)index forComponent:(int)component;

@end


@protocol ChosenSettingsModelDelegate

- (void)chosenSettingsModel:(ChosenSettingsModel *)sender
		   changedComponent:(int)component
					toIndex:(int)index;

@end
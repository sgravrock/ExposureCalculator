//
//  ArrayDataSource.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/10/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayDataSource : NSObject<UIPickerViewDataSource>

// components is an NSArray of one or more NSArray instances, each of which will provide
// data for one of the picker view's wheels.
@property (nonatomic, strong) NSArray *components;

@end

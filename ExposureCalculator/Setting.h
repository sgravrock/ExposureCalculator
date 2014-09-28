//
//  Setting.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/24/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

@property (nonatomic, readonly, assign) NSUInteger component;
@property (nonatomic, readonly, strong) NSNumber *value;

+ (Setting *)settingWithComponent:(NSUInteger)component value:(NSNumber *)value;
+ (NSString *)formatSettingWithComponent:(NSUInteger)component value:(NSNumber *)value;

@end

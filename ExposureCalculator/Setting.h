//
//  Setting.h
//  ExposureCalculator
//
//  Created by Steve Gravrock on 2/24/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

@property (nonatomic, readonly, assign) int component;
@property (nonatomic, readonly, strong) NSNumber *value;

+ (Setting *)settingWithComponent:(int)component value:(NSNumber *)value;
+ (NSString *)formatSettingWithComponent:(int)component value:(NSNumber *)value;

@end
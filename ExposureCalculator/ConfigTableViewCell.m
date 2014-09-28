//
//  ConfigTableViewCell.m
//  ExposureCalculator
//
//  Created by Steve Gravrock on 9/27/14.
//  Copyright (c) 2014 Steve Gravrock. All rights reserved.
//

#import "ConfigTableViewCell.h"

@implementation ConfigTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
			  reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor whiteColor];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	self.textLabel.textColor = selected ? [UIColor blackColor] : [UIColor whiteColor];
}

@end

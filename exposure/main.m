//
//  main.m
//  exposure
//
//  Created by Steve Gravrock on 2/16/13.
//  Copyright (c) 2013 Steve Gravrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Calculator.h"
#import "CliUtils.h"

static void usage(const char *pname);

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		NSNumber *aperture = nil;
		NSNumber *shutter = nil;
		NSNumber *iso = nil;
		int i = 1;
		
		while (i < argc - 1) {
			const char *arg = argv[i++];
			
			if (strcmp(arg, "-a") == 0) {
				aperture = [CliUtils apertureFromString:argv[i++]];
			} else if (strcmp(arg, "-s") == 0) {
				shutter = [CliUtils shutterFromString:argv[i++]];
			} else if (strcmp(arg, "-i") == 0) {
				iso = [CliUtils intFromString:argv[i++]];
			} else {
				usage(argv[0]);
			}
		}
		
		if (aperture && shutter && iso) {
			int lv = [Calculator thirdsLvForAperture:[aperture doubleValue]
									   shutter:[shutter doubleValue]
										 sensitivity:[iso intValue]];
			int whole = lv / 3;
			int fract = lv % 3;
			
			if (fract == 0) {
				printf("%d\n", whole);
			} else {
				// Round to the conventional points
				printf("%d.%d\n", whole, fract == 1 ? 3 : 7);
			}
		} else {
			usage(argv[0]);
		}
	}
	
    return 0;
}

static void usage(const char *pname)
{
	fprintf(stderr, "Usage: %s -a aperture -s shutter -i iso\n", pname);
	exit(EXIT_FAILURE);
}

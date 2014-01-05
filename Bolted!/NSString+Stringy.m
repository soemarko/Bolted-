//
//  NSString+Stringy.m
//  Bolted!
//
//  Created by Soemarko Ridwan on 1/5/14.
//  Copyright (c) 2014 Soemarko Ridwan. All rights reserved.
//

#import "NSString+Stringy.h"

@implementation NSString (Stringy)

- (NSString *)stringByStrippingHTML {
	NSRange r;
	NSString *s = [self copy];
	while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		s = [s stringByReplacingCharactersInRange:r withString:@""];
	return s;
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSScanner* scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

@end

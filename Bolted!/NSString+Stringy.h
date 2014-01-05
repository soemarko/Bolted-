//
//  NSString+Stringy.h
//  Bolted!
//
//  Created by Soemarko Ridwan on 1/5/14.
//  Copyright (c) 2014 Soemarko Ridwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Stringy)

- (NSString *)stringByStrippingHTML;
- (NSString *)stringBetweenString:(NSString*)start andString:(NSString*)end;

@end

//
//  NSTextField-TextManipulation.h
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TextManipulation)

- (void)appendString:(NSString *)text;
- (void)appendString:(NSString *)text withFont:(NSFont *)font;
- (void)appendString:(NSString *)text withFont:(NSFont *)font andColor:(NSColor *)color;
- (void)appendString:(NSString *)text withColor:(NSColor *)color;
- (void)removeLastChar;
- (NSRange)lastCharRange;
- (void)invertTextColorForRange:(NSRange)range;

@end

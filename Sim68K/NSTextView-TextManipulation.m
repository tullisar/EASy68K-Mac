//
//  NSTextField-TextManipulation.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSTextView-TextManipulation.h"

@implementation NSTextView (TextManipulation)

// -----------------------------------------------------------------
// appendString
// Appends a string to the end of the text field's text storage
// -----------------------------------------------------------------
- (void)appendString:(NSString *)text {
    NSTextStorage *store = [self textStorage];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc]
                                          initWithString:text];
    NSRange wholeString = NSMakeRange(0, [text length]);
    [store appendAttributedString:newText];
}

// -----------------------------------------------------------------
// appendString withFont
// Appends a string to the end of the text field's text storage
// using the specified font
// -----------------------------------------------------------------
- (void)appendString:(NSString *)text withFont:(NSFont *)font {
    NSTextStorage *store = [self textStorage];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc]
                                          initWithString:text];
    NSRange wholeString = NSMakeRange(0, [text length]);
    [newText addAttribute:NSFontAttributeName
                    value:font
                    range:wholeString];
    [store appendAttributedString:newText];    
}

// -----------------------------------------------------------------
// appendString withFont andColor
// Appends a string to the end of the text field's text storage
// using the specified font and color
// -----------------------------------------------------------------
- (void)appendString:(NSString *)text withFont:(NSFont *)font andColor:(NSColor *)color {
    NSTextStorage *store = [self textStorage];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc]
                                          initWithString:text];
    NSRange wholeString = NSMakeRange(0, [text length]);
    [newText addAttribute:NSFontAttributeName
                    value:font
                    range:wholeString];
    [newText addAttribute:NSForegroundColorAttributeName
                    value:color
                    range:wholeString];
    [store appendAttributedString:newText]; 
}

// -----------------------------------------------------------------
// appendString withColor
// Appends a string to the end of the text field's text storage
// using the specified color
// -----------------------------------------------------------------
- (void)appendString:(NSString *)text withColor:(NSColor *)color {
    NSTextStorage *store = [self textStorage];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc]
                                          initWithString:text];
    NSRange wholeString = NSMakeRange(0, [text length]);
    [newText addAttribute:NSForegroundColorAttributeName
                    value:color
                    range:wholeString];
    [store appendAttributedString:newText];     
}

// -----------------------------------------------------------------
// removeLastChar
// Removes the last (ending) character from the text field's storage
// -----------------------------------------------------------------
- (void)removeLastChar {
    NSTextStorage *store = [self textStorage];
    [store deleteCharactersInRange:[self lastCharRange]];
}

// -----------------------------------------------------------------
// lastCharRange
// Gets the NSRange represented by the last character in the text
// storage
// -----------------------------------------------------------------
- (NSRange)lastCharRange {
    NSTextStorage *store = [self textStorage];
    NSMutableString *text = [store mutableString];
    return NSMakeRange([text length]-1,[text length]);    
}

// -----------------------------------------------------------------
// lastCharRange
// Gets the NSRange represented by the last character in the text
// storage
// -----------------------------------------------------------------
- (void)invertTextColorForRange:(NSRange)range {
    
}
@end

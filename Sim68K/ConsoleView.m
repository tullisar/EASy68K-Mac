//
//  ConsoleView.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConsoleView.h"
#include "extern.h"

@implementation ConsoleView

// -----------------------------------------------------------------
// initWithFrame
// Default initialization for the textView
// -----------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        pendingKeyChar[0] = pendingKeyChar[1] = '\0';
        inputIndex = 0;
        inputEnabled = NO;
        
        // TODO: Disable paste
    }
    return self;
}

// -----------------------------------------------------------------
// drawRect
// Paint method for updating display if necesary
// -----------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

// -----------------------------------------------------------------
// keyDown
// Overrides the keyDown to handle text input
// -----------------------------------------------------------------
- (void)keyDown:(NSEvent *)theEvent {
    sprintf(pendingKeyChar, "%s", [[theEvent characters] cStringUsingEncoding:NSUTF8StringEncoding]);
    pendingKey = true;
    if (inputEnabled) {
        BOOL returnKey = NO;
        if (*pendingKeyChar == '\r') {
            returnKey = YES;
        }
        returnKey = NO;
    }
}

// -----------------------------------------------------------------
// textIn
// Allows for text input!
// -----------------------------------------------------------------
- (void)textIn:(char *)str sizePtr:(long *)size regNum:(long *)inNum {
    inputEnabled = YES;
    inSize = size;
    inBuf = str;
    inDest = inNum;
}

// -----------------------------------------------------------------
// textOut
// Outputs a string to the I/O Window without a newline
// -----------------------------------------------------------------
- (void)textOut:(char *)str {
    // TODO: Dispatch to main thread to be save
    NSTextStorage *store = [self textStorage];
    NSString *line = [NSString stringWithFormat:@"%s",str];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc]
                                          initWithString:line];
    NSRange wholeString = NSMakeRange(0, [line length]);
    [newText addAttribute:NSForegroundColorAttributeName
                    value:[NSColor whiteColor]
                    range:wholeString];
    [newText addAttribute:NSFontAttributeName
                    value:[NSFont fontWithName:@"Courier" size:11]
                    range:wholeString];
     
    [store appendAttributedString:newText];
}

// -----------------------------------------------------------------
// textOutCR
// Outputs a string to the I/O Window with a newline
// -----------------------------------------------------------------
- (void)textOutCR:(char *)str {
    char buf[256];
    sprintf(buf, "%s\n", str);
    [self textOut:buf];
}

@end

//
//  ConsoleView.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConsoleView.h"
#import "Simulator.h"
#include "extern.h"

@implementation ConsoleView

// -----------------------------------------------------------------
// initWithFrame
// Default initialization for the textView
// -----------------------------------------------------------------
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        row = col = textX = textY = x = y = 0;
        for (int i = 0; i < KEYBUF_SIZE; i++) {
            eventKeyBuffer[i] = '\0';
            keyBuf[i] = '\0';
        }
        keyI = 0;
        inputMode = NO;
        charInput = NO;
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
// paste
// Overrides the paste method to disallow pasting of text
// TODO: Allow pasting during input strings
// -----------------------------------------------------------------
//- (void)paste:(id)sender {
//    [super paste:sender];
//}

// -----------------------------------------------------------------
// keyDown
// Overrides the keyDown to handle text input
// -----------------------------------------------------------------
- (void)keyDown:(NSEvent *)theEvent {
    sprintf(eventKeyBuffer, "%s", [[theEvent characters] cStringUsingEncoding:NSUTF8StringEncoding]);
    char key = eventKeyBuffer[0];
    if (inputMode) {
        // if Enter key, limit reached, or char input
        if (key == '\r' || keyI >= 79 || charInput) {
            // TODO: Erase prompt
            if (charInput) {
                *inChar = key;                          // get key
                charInput = NO;
                if (keyboardEcho) {
                    // [self charOut:key];
                    if (key == '\r' && inputLFdisplay) { // if CR and LF display wanted
                        // [self charOut:'\n'];           // do LF
                    }
                }
            }
            else {
                // TODO: Display CRLF
                
            }
        }
        
    }
    
}

// -----------------------------------------------------------------
// textIn
// Allows for text input!
// -----------------------------------------------------------------
- (void)textIn:(char *)str sizePtr:(long *)size regNum:(long *)inNum {

    userBuf     = str;
    inputLength = size;
    inputNumber = inNum;
    keyI        = 0;
    inputMode   = YES:
    [[appDelegate simulator] setSimInputMode:NO];
    
    if (pendingKey) {
        NSEvent *formKeyPress = [NSEvent keyEventWithType:NSKeyDown 
                                                 location:NSMakePoint(0, 0) 
                                            modifierFlags:0 
                                                timestamp:nil
                                             windowNumber:0
                                                  context:nil 
                                               characters:[NSString stringWithFormat:@"%c",pendingKey]
                              charactersIgnoringModifiers:[NSString stringWithFormat:@"%c",pendingKey]
                                                isARepeat:NO 
                                                  keyCode:0];
        [self keyDown:formKeyPress];
        pendingKey = 0;
    }
    
    if (inputPrompt) {
        // TODO: Flash input prompt with NSTimer
    }
    
    
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

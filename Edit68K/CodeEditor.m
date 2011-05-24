//
//  CodeEditor.m
//  Edit68K
//
//  Created by Robert Bartlett-Schneider on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeEditor.h"
#include "Edit68KMac.h"

@implementation CodeEditor

// -----------------------------------------------------------------
// init
// Default initialization for the textView
// -----------------------------------------------------------------
-(id)init {
    self = [super init];
    if (self) {

        
    }
    return self;
}

// -----------------------------------------------------------------
// awakeFromNib
// Called when loaded from the nib file
// -----------------------------------------------------------------
-(void)awakeFromNib {
    
}

// -----------------------------------------------------------------
// keyDown
// Overrides the keyDown event in order to intercept tabs event
// -----------------------------------------------------------------
-(void)keyDown:(NSEvent *)theEvent {
 
    NSString    *key, *rawText, *lineText, *trimText, *indentString;
    NSMutableString *spaces;
    NSRange     lineRange, cursorRange;
    int         indentLength, tabWidth, tabType;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    key = [theEvent characters];

    // Auto-indent on new-lines
    if ([key isEqualToString:@"\r"]) {
        
        // Get cursor location & affected area
        cursorRange = [[[self selectedRanges] objectAtIndex:0] rangeValue];
        cursorRange.length = 0;
        rawText = [[self textStorage] string];
        
        // Get the old line text & find it's indentation
        lineRange = [rawText lineRangeForRange:cursorRange];
        lineText  = [rawText substringWithRange:lineRange];
        trimText = [lineText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        indentLength = [lineText length] - [trimText length];
        
        // Indent the new string after applying the key event
        indentString = [lineText substringToIndex:indentLength];
        [super keyDown:theEvent];
        cursorRange = [[[self selectedRanges] objectAtIndex:0] rangeValue];
        cursorRange.length = 0;
        [self insertText:indentString];
    
    // Tab or space depending on tab type preference
    } else if ([key isEqualToString:@"\t"]) {
        
        // Determine tab preferences
        tabType = [ud integerForKey:@"tabType"];
        tabWidth = [ud integerForKey:@"tabWidthInSpaces"];
        
        // Either handle as standard tab (super handles) or by inserting spaces
        if ( tabType == kTabTypeAssembly ) [super keyDown:theEvent];
        else {
            spaces = [NSMutableString string];
            for (int i = 0; i < tabWidth; i++) {
                [spaces appendString:@" "];
            }
            [self insertText:spaces];
        }
       
    // Normal key
    } else {
        [super keyDown:theEvent];
    }

    
}


@end

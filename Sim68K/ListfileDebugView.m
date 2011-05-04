//
//  ListfileDebugView.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// Based on MouseOverTextView.m
// LayoutManager Demo in Apple Developer Documentation
// License follows:

/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation, 
 modification or redistribution of this Apple software constitutes acceptance of these 
 terms.  If you do not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject to these 
 terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in 
 this original Apple software (the "Apple Software"), to use, reproduce, modify and 
 redistribute the Apple Software, with or without modifications, in source and/or binary 
 forms; provided that if you redistribute the Apple Software in its entirety and without 
 modifications, you must retain this notice and the following text and disclaimers in all 
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks 
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from 
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your 
 derivative works or by other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, 
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, 
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS 
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND 
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR 
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ListfileDebugView.h"

#include "extern.h"

@implementation ListfileDebugView

// -----------------------------------------------------------------
// mouseDown
// Intercepts the mouseDown event for the listFile view in order
// to highlight the entire line with selected text color
// -----------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent {
    
    NSLayoutManager *layoutManager = [self layoutManager];
    NSTextContainer *textContainer = [self textContainer];
    unsigned glyphIndex, charIndex, textLength = [[self textStorage] length];
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRange lineGlyphRange, lineCharRange, wordCharRange, textCharRange = NSMakeRange(0, textLength);
    NSRect glyphRect;
    
    // Remove any existing coloring.
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:textCharRange];
    
    // Convert view coordinates to container coordinates
    point.x -= [self textContainerOrigin].x;
    point.y -= [self textContainerOrigin].y;
    
    // Convert those coordinates to the nearest glyph index
    glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
    
    // Check to see whether the mouse actually lies over the glyph it is nearest to
    glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];
    
    if (NSPointInRect(point, glyphRect)) {
        // Convert the glyph index to a character index
        charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        
        // Determine the range of glyphs, and of characters, in the corresponding line
        (void)[layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&lineGlyphRange];        
        lineCharRange = [layoutManager characterRangeForGlyphRange:lineGlyphRange actualGlyphRange:NULL];
        
        // Determine the word containing that character
        wordCharRange = NSIntersectionRange(lineCharRange, [self selectionRangeForProposedRange:NSMakeRange(charIndex, 0) granularity:NSSelectByWord]);
        
        // Color the characters using temporary attributes
        [layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor selectedTextBackgroundColor], NSBackgroundColorAttributeName, nil] forCharacterRange:lineCharRange];
    }
}
    
// -----------------------------------------------------------------
// rightMouseDown
// Intercepts the rightMouseDown event in order to highlight
// entire line with selected text color
// -----------------------------------------------------------------
- (void)rightMouseDown:(NSEvent *)theEvent {
    [self mouseDown:theEvent];
}

// -----------------------------------------------------------------
// otherMouseDown
// Intercepts middle mouse button click to replicate left/right click
// -----------------------------------------------------------------
- (void)otherMouseDown:(NSEvent *)theEvent {
    [self mouseDown:theEvent];
}

// -----------------------------------------------------------------
// highlightCurrentInstruction
// Highlights the current instruction about to be executed
// -----------------------------------------------------------------
- (void)highlightCurrentInstruction {
    
    NSLayoutManager *layoutManager = [self layoutManager];
    // NSTextContainer *textContainer = [self textContainer];
    unsigned textLength = [[self textStorage] length];
    NSRange lineRange, searchRange, pcLocation, textCharRange = NSMakeRange(0, textLength);
    NSString *pcString = [NSString stringWithFormat:@"%08X  ",PC];
    NSString *line;
    NSMutableString *listText = [[self textStorage] mutableString];
    
    
    // Remove any existing coloring.
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:textCharRange];
    
    // Search for the actual instruction at the current PC
    BOOL instructionFound = NO;
    searchRange = textCharRange;
    while (!instructionFound ) {
        // Locate PC in listFile text
        pcLocation = [listText rangeOfString:pcString options:NSCaseInsensitiveSearch range:searchRange];
        if (pcLocation.location == NSNotFound) return;
        lineRange = [listText lineRangeForRange:pcLocation];
        line = [listText substringWithRange:lineRange];
        if ([appDelegate isInstruction:line]) {
            instructionFound = YES;
        } else {
            searchRange = NSMakeRange((lineRange.location+10), textLength - (lineRange.location+10));
        }
    }
    
    // Color the characters using temporary attributes
    [layoutManager addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor selectedTextBackgroundColor], NSBackgroundColorAttributeName, nil] forCharacterRange:lineRange];
    
}

@end

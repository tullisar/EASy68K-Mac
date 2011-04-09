//
//  AssemblyListFileView.m
//  Used to display line numbers with breakpoint support in viewing
//  listfiles for assembly language.
//
//  Subclass Author: Robert Bartlett-Schneider
// 
//  Subclass of NoodleLineNumberView
//  Created by Paul Kim on 9/28/08.
//  Copyright (c) 2008 Noodlesoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "AsssemblyListfileView.h"

@implementation AsssemblyListfileView

//- (NoodleLineNumberMarker *)markerAtLine:(unsigned)line
//{
//	return [linesToMarkers objectForKey:[NSNumber numberWithUnsignedInt:line - 1]];
//}
//
//- (unsigned)lineNumberForCharacterIndex:(unsigned)index inText:(NSString *)text
//{
//    unsigned			left, right, mid, lineStart;
//	NSMutableArray		*lines;
//    
//	lines = [self lineIndices];
//	
//    // Binary search
//    left = 0;
//    right = [lines count];
//    
//    while ((right - left) > 1)
//    {
//        mid = (right + left) / 2;
//        lineStart = [[lines objectAtIndex:mid] unsignedIntValue];
//        
//        if (index < lineStart)
//        {
//            right = mid;
//        }
//        else if (index > lineStart)
//        {
//            left = mid;
//        }
//        else
//        {
//            return mid;
//        }
//    }
//    return left;
//}
//
//- (NSDictionary *)textAttributes
//{
//    return [NSDictionary dictionaryWithObjectsAndKeys:
//            [self font], NSFontAttributeName, 
//            [self textColor], NSForegroundColorAttributeName,
//            nil];
//}
//
//- (NSDictionary *)markerTextAttributes
//{
//    return [NSDictionary dictionaryWithObjectsAndKeys:
//            [self font], NSFontAttributeName, 
//            [self alternateTextColor], NSForegroundColorAttributeName,
//            nil];
//}
//
//- (CGFloat)requiredThickness
//{
//    unsigned			lineCount, digits, i;
//    NSMutableString     *sampleString;
//    NSSize              stringSize;
//    
//    lineCount = [[self lineIndices] count];
//    digits = (unsigned)log10(lineCount) + 1;
//	sampleString = [NSMutableString string];
//    for (i = 0; i < digits; i++)
//    {
//        // Use "8" since it is one of the fatter numbers. Anything but "1"
//        // will probably be ok here. I could be pedantic and actually find the fattest
//		// number for the current font but nah.
//        [sampleString appendString:@"8"];
//    }
//    
//    stringSize = [sampleString sizeWithAttributes:[self textAttributes]];
//    
//	// Round up the value. There is a bug on 10.4 where the display gets all wonky when scrolling if you don't
//	// return an integral value here.
//    return ceilf(MAX(DEFAULT_THICKNESS, stringSize.width + RULER_MARGIN * 2));
//}
//
//- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect
//{
//    id			view;
//	NSRect		bounds;
//    
//	bounds = [self bounds];
//    
//	if (backgroundColor != nil)
//	{
//		[backgroundColor set];
//		NSRectFill(bounds);
//		
//		[[NSColor colorWithCalibratedWhite:0.58 alpha:1.0] set];
//		[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(bounds) - 0/5, NSMinY(bounds)) toPoint:NSMakePoint(NSMaxX(bounds) - 0.5, NSMaxY(bounds))];
//	}
//	
//    view = [self clientView];
//	
//    if ([view isKindOfClass:[NSTextView class]])
//    {
//        NSLayoutManager			*layoutManager;
//        NSTextContainer			*container;
//        NSRect					visibleRect, markerRect;
//        NSRange					range, glyphRange, nullRange;
//        NSString				*text, *labelText;
//        unsigned				rectCount, index, line, count;
//        NSRectArray				rects;
//        float					ypos, yinset;
//        NSDictionary			*textAttributes, *currentTextAttributes;
//        NSSize					stringSize, markerSize;
//		NoodleLineNumberMarker	*marker;
//		NSImage					*markerImage;
//		NSMutableArray			*lines;
//        
//        layoutManager = [view layoutManager];
//        container = [view textContainer];
//        text = [view string];
//        nullRange = NSMakeRange(NSNotFound, 0);
//		
//		yinset = [view textContainerInset].height;        
//        visibleRect = [[[self scrollView] contentView] bounds];
//        
//        textAttributes = [self textAttributes];
//		
//		lines = [self lineIndices];
//        
//        // Find the characters that are currently visible
//        glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
//        range = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
//        
//        // Fudge the range a tad in case there is an extra new line at end.
//        // It doesn't show up in the glyphs so would not be accounted for.
//        range.length++;
//        
//        count = [lines count];
//        index = 0;
//        
//        for (line = [self lineNumberForCharacterIndex:range.location inText:text]; line < count; line++)
//        {
//            index = [[lines objectAtIndex:line] unsignedIntValue];
//            
//            if (NSLocationInRange(index, range))
//            {
//                rects = [layoutManager rectArrayForCharacterRange:NSMakeRange(index, 0)
//                                     withinSelectedCharacterRange:nullRange
//                                                  inTextContainer:container
//                                                        rectCount:(NSUInteger *)&rectCount];
//				
//                if (rectCount > 0)
//                {
//                    // Note that the ruler view is only as tall as the visible
//                    // portion. Need to compensate for the clipview's coordinates.
//                    ypos = yinset + NSMinY(rects[0]) - NSMinY(visibleRect);
//					
//					marker = [linesToMarkers objectForKey:[NSNumber numberWithUnsignedInt:line]];
//					
//					if (marker != nil)
//					{
//						markerImage = [marker image];
//						markerSize = [markerImage size];
//						markerRect = NSMakeRect(0.0, 0.0, markerSize.width, markerSize.height);
//                        
//						// Marker is flush right and centered vertically within the line.
//						markerRect.origin.x = NSWidth(bounds) - [markerImage size].width - 1.0;
//						markerRect.origin.y = ypos + NSHeight(rects[0]) / 2.0 - [marker imageOrigin].y;
//                        
//						[markerImage drawInRect:markerRect fromRect:NSMakeRect(0, 0, markerSize.width, markerSize.height) operation:NSCompositeSourceOver fraction:1.0];
//					}
//                    
//                    // Line numbers are internally stored starting at 0
//                    labelText = [NSString stringWithFormat:@"%d", line + 1];
//                    
//                    stringSize = [labelText sizeWithAttributes:textAttributes];
//                    
//					if (marker == nil)
//					{
//						currentTextAttributes = textAttributes;
//					}
//					else
//					{
//						currentTextAttributes = [self markerTextAttributes];
//					}
//					
//                    // Draw string flush right, centered vertically within the line
//                    [labelText drawInRect:
//                     NSMakeRect(NSWidth(bounds) - stringSize.width - RULER_MARGIN,
//                                ypos + (NSHeight(rects[0]) - stringSize.height) / 2.0,
//                                NSWidth(bounds) - RULER_MARGIN * 2.0, NSHeight(rects[0]))
//                           withAttributes:currentTextAttributes];
//                }
//            }
//			if (index > NSMaxRange(range))
//			{
//				break;
//			}
//        }
//    }
//}
//
//- (void)setMarkers:(NSArray *)markers
//{
//	NSEnumerator		*enumerator;
//	NSRulerMarker		*marker;
//	
//	[linesToMarkers removeAllObjects];
//	[super setMarkers:nil];
//    
//	enumerator = [markers objectEnumerator];
//	while ((marker = [enumerator nextObject]) != nil)
//	{
//		[self addMarker:marker];
//	}
//}
//
//- (void)addMarker:(NSRulerMarker *)aMarker
//{
//	if ([aMarker isKindOfClass:[NoodleLineNumberMarker class]])
//	{
//		[linesToMarkers setObject:aMarker
//                           forKey:[NSNumber numberWithUnsignedInt:[(NoodleLineNumberMarker *)aMarker lineNumber] - 1]];
//	}
//	else
//	{
//		[super addMarker:aMarker];
//	}
//}
//
//- (void)removeMarker:(NSRulerMarker *)aMarker

@end

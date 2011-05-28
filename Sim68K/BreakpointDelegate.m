/***************************** 68000 SIMULATOR ****************************
 
 File Name: BreakpointDelegate.m
 Version: 1.0 (Mac OS X)
 
 Implementation file for the breakpoint delegate that handles setting of
 68K breakpoints. This will eventually be used to handle advanced breakpoints
 by being a data source for the table view that handles advanced breakpoints.
 
 The routines are :
 
 sbpoint
 cbpoint
 
 Created:  2011-04-15
 Robert Bartlett-Schneider
 
 ***************************************************************************/

#import "BreakpointDelegate.h"
#include "extern.h"

@implementation BreakpointDelegate

@synthesize sizeStrings, errString, breakError;
@synthesize regBreakpoints, regOpStrings, validRegList, selRegBP, selReg, selRegOp, selRegValue, selRegSize;
@synthesize memOpStrings, memRWStrings;

// -----------------------------------------------------------------
// sbpoint
// Sets a PC breakpoint
// -----------------------------------------------------------------
+ (int)sbpoint:(int)loc {
    for (int i = 0; i < bpoints; i++)
        if (brkpt[i] == loc)
            return SUCCESS;
    
    if (bpoints < MAX_BPOINTS)
        brkpt[bpoints++] = loc;
    else
        [SimErrorManager log:@"Breakpoint limit reached!"];
 
    return SUCCESS;
}

// -----------------------------------------------------------------
// cbpoint
// Clears a PC breakpoint
// -----------------------------------------------------------------
+ (int)cbpoint:(int)loc {
    int i, j;
    if (loc == -1)                      // clear all breakpoints
        bpoints = 0;
    else {
        for (i = 0; i < bpoints; i++)   // clear single breakpoint
            if (brkpt[i] == loc)
                break;
        --bpoints;
        for (j = i; j < bpoints; j++)   // adjust breakpoint table
            brkpt[j] = brkpt[j+1];
    }
    
    return SUCCESS;
}

// -----------------------------------------------------------------
// awakeFromNib
// Runs when the NIB file has been loaded.
// -----------------------------------------------------------------
- (void)awakeFromNib {    
    
    // Initialize size combo-box values & other window generic stuff
    [self setSizeStrings:
     [NSArray arrayWithObjects:@"Byte", @"Word", @"Long", nil]];
    [self setErrString:@""];
    [self setBreakError:NO];
    
    // Initialize controls for PC/Register breakpoints
    [self setRegBreakpoints:[NSMutableArray arrayWithCapacity:(MAX_BPOINTS)/2+1]];
    [self updateRegBPList];
    [self setRegOpStrings:
     [NSArray arrayWithObjects:@"==", @"!=", @">", @">=", @"<", @"<=", nil]];
    [self setValidRegList:
     [NSArray arrayWithObjects:@"D0", @"D1", @"D2", @"D3", @"D4", @"D5", @"D6", @"D7", 
      @"A0", @"A1", @"A2", @"A3", @"A4", @"A5", @"A6", @"A7", @"PC", nil]];
    [self setSelReg:0];
    [self setSelRegOp:0];
    [self setSelRegValue:0x00000000];
    [self setSelRegSize:0];
    
    // Initialize controls for Address breakpoints
    [self setMemOpStrings:
     [NSArray arrayWithObjects:@"==", @"!=", @">", @">=", @"<", @"<=", @"N/A", nil]];
    [self setMemRWStrings:
     [NSArray arrayWithObjects:@"R/W", @"R", @"W", @"N/A", nil]];
    
    // Initialize controls for Breakpoint expressions
    
}

// -----------------------------------------------------------------
// setRegBP
// Sets a PC / Register breakpoint
// -----------------------------------------------------------------
- (IBAction)setRegBP:(id)sender {
    
    int selection = [self selRegBP];
    if (selection < 1) return;
    
    // Set the register breakpoint using currently selected information
    BPoint *curBPoint = &breakPoints[selection-1];
    curBPoint->setId(regCount);
    curBPoint->setType(PC_REG_TYPE);
    curBPoint->setTypeId([self selReg]);
    curBPoint->setOperator([self selRegOp]);
    curBPoint->setValue([self selRegValue]);
    curBPoint->setSize([self selRegSize]);
    curBPoint->isEnabled(true);
    
    if (selection > regCount) regCount++;
    [self updateRegBPList];
    [self setSelRegBP:selection];
}

// -----------------------------------------------------------------
// clearRegBP
// Clears a PC / Register breakpoint
// -----------------------------------------------------------------
- (IBAction)clearRegBP:(id)sender {
    
    int selection = [self selRegBP];
    if (selection < 1 || selection > regCount) return;

    // Shift the elements in the breakPoints array and decrement the count.
    BPoint *temp = &breakPoints[selection-1];
    for(int curRow = selection; curRow < regCount; curRow++) {
        breakPoints[curRow - 1] = breakPoints[curRow];
    }
    regCount--;
    breakPoints[regCount] = *temp;
    breakPoints[regCount].isEnabled(false);
    
    [self updateRegBPList];
    if ((selection > regCount) && (selection > 1)) selection = regCount;
    [self setSelRegBP:selection];
}

// -----------------------------------------------------------------
// clearAllRegBP
// Clears a PC / Register breakpoint
// -----------------------------------------------------------------
- (IBAction)clearAllRegBP:(id)sender {
    
    // Invalidate all PC/Reg breakpoints
    for(int cur = 0; cur < regCount; cur++)
        breakPoints[cur].isEnabled(false);
    regCount = 0;
    
    // Update display
    [self updateRegBPList];
    [self setSelRegBP:1];
    
}

// -----------------------------------------------------------------
// updateRegBPList
// Updates the list of pc/register breakpoints
// -----------------------------------------------------------------
- (void)updateRegBPList {
    
    NSMutableArray  *worker;
    NSString        *line, *textLine;
    NSTextStorage   *textStore;
    BPoint          *curBPoint;
    NSRange         textRange;
    NSDictionary    *textAttr;
    
    // Reset the list of options and regenerate
    worker = [self regBreakpoints];
    [worker removeAllObjects];
    [regBPList clearText];
    [regBPList setFont:[NSFont fontWithName:@"Courier" size:10]];
    [regBPList appendString:@"     Reg Op Value      Size\n"];
    [worker addObject:@"Select Register Breakpoint"];
    for (int i = 1; i <= regCount; i++) {
        curBPoint = &breakPoints[i-1];
        line = [NSString stringWithFormat:@"%d %@ %@ 0x%08X (%@)",
                i,
                [[self validRegList] objectAtIndex:(curBPoint->getTypeId())],
                [[self regOpStrings] objectAtIndex:(curBPoint->getOperator())],
                curBPoint->getValue(),
                [[self sizeStrings] objectAtIndex:(curBPoint->getSize())]];
        [worker addObject:line];
        
        [regBPList appendString:[NSString stringWithFormat:@"(%d) ",i]];
        if (i < 10) [regBPList appendString:@" "];
        textLine = [NSString stringWithFormat:@"%@  ",
                    [[self validRegList] objectAtIndex:(curBPoint->getTypeId())]];
        [regBPList appendString:textLine];
        textLine = [NSString stringWithFormat:@"%@ ",
                    [[self regOpStrings] objectAtIndex:(curBPoint->getOperator())]];
        [regBPList appendString:textLine];
        if ([textLine length] < 3) [regBPList appendString:@" "];
        [regBPList appendString:[NSString stringWithFormat:@"0x%08X (%@)\n",
                                 (curBPoint->getValue()),
                                 [[self sizeStrings] objectAtIndex:(curBPoint->getSize())]]];
    }
    
    // Placeholder for new breakpoint
    if (regCount < (MAX_BPOINTS/2)) {
        line = [NSString stringWithFormat:@"%d New PC / Register breakpoint...",regCount+1];
        [worker addObject:line];
    }
    
    // Ensure font & color are correct for HUD window text
    textStore = [regBPList textStorage];
    textRange = NSMakeRange(0, [textStore length]);
    textAttr  = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSColor whiteColor], NSForegroundColorAttributeName,
                 [NSFont fontWithName:@"Courier" size:10], NSFontAttributeName, nil];
    [textStore setAttributes:textAttr range:textRange];
    
    // Update the mutable array binding
    [self setRegBreakpoints:worker];
}


@end

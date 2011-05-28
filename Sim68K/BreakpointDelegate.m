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

@end

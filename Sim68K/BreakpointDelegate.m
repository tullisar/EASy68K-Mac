//
//  BreakpointDelegate.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

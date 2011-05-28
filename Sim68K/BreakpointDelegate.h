/***************************** 68000 SIMULATOR ****************************
 
 File Name: BreakpointDelegate.h
 Version: 1.0 (Mac OS X)
 
 This is the definition file for the breakpoint delegate to handle setting
 breakpoints.
 
 The routines are :
 
 sbpoint
 cbpoint
 
 Created:  2011-04-15
           Robert Bartlett-Schneider
 
 ***************************************************************************/
#import <Cocoa/Cocoa.h>

@interface BreakpointDelegate : NSObject {
    
}

+ (int)sbpoint:(int)loc;
+ (int)cbpoint:(int)loc;

@end

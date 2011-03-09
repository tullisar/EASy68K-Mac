//
//  Sim68KAppDelegate.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 2/27/11.
//

#import "Sim68KAppDelegate.h"
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLineNumberView.h"
#import "Simulator.h"
#import "IntHexStringTransformer.h"
#import "ShortHexStringTransformer.h"
#import "ShortBinaryStringTransformer.h"

//#import <BWToolkitFramework/BWToolkitFramework.h>

@implementation Sim68KAppDelegate

@synthesize window, panelIO, panelMemory, panelStack, panelHardware;

// -----------------------------------------------------------------
// initialize
// -----------------------------------------------------------------
+ (void) initialize {
    NSValueTransformer *intHexStr = [[IntHexStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:intHexStr
                                    forName:@"IntHexStringTransformer"];
    NSValueTransformer *shortHexStr = [[ShortHexStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:shortHexStr
                                    forName:@"ShortHexStringTransfomer"];
    NSValueTransformer *shortBinStr = [[ShortBinaryStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:shortBinStr
                                    forName:@"ShortBinaryStringTransformer"];
    [intHexStr autorelease];
    [shortHexStr autorelease];
    [shortBinStr autorelease];
}


// -----------------------------------------------------------------
// applicationDidFinishLaunching
// This runs (usually before the NIB loads) but as soon as the 
// application has finished launching.
// -----------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {}

// -----------------------------------------------------------------
// displayReg
// Updates all the GUI registers to match those of the 68000 simulator
// -----------------------------------------------------------------
- (void)awakeFromNib {
    
    // Initialize the NSTextView with the NoodleLineNumberView
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
    [scriptView setFont:[NSFont fontWithName:@"Courier" size:11]];
    
    // Initialize the simulator
    [simulator initSim];
    [simulator displayReg];
    
    [window makeKeyAndOrderFront:self];
}

// -----------------------------------------------------------------
// openDocument
// Load an sRecord file from the disk to begin simulation.
// -----------------------------------------------------------------
- (IBAction)openDocument:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"s68"]];
    [openPanel beginSheetModalForWindow:window 
                      completionHandler:^(NSInteger result) {
                          
                          if (result == NSFileHandlingPanelOKButton) {
                              [simulator loadProgram:[[openPanel URL] path]];
                              // TODO: Set Title Bar
                          }
                      }];
}


@end

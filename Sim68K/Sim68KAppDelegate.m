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
#import "UShortHexStringTransformer.h"
#import "UShortBinaryStringTransformer.h"
#import "TripleSynchronizedScrollView.h"

#include "extern.h"

//#import <BWToolkitFramework/BWToolkitFramework.h>

@implementation Sim68KAppDelegate

@synthesize window, panelIO, panelMemory, panelStack, panelHardware, simIOView;
@synthesize file;
@synthesize simulator;

// -----------------------------------------------------------------
// initialize
// -----------------------------------------------------------------
+ (void) initialize {
    NSValueTransformer *intHexStr = [[IntHexStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:intHexStr
                                    forName:@"IntHexStringTransformer"];
    NSValueTransformer *shortHexStr = [[UShortHexStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:shortHexStr
                                    forName:@"UShortHexStringTransfomer"];
    NSValueTransformer *shortBinStr = [[UShortBinaryStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:shortBinStr
                                    forName:@"UShortBinaryStringTransformer"];
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
// awakeFromNib
// Runs when the NIB file has been loaded.
// -----------------------------------------------------------------
- (void)awakeFromNib {    
    // Global delegate reference (ick), necessary for simulator functions to reference GUI
    appDelegate = self;
    
    [self initListfileView];             // Set up listfile view
    [self initMemoryScrollers];
    [simulator initSim];                 // Initialize simulator
    
    memDisplayLength = 1024;             // Set up memory browser values
    [self setMemDisplayStart:0x1000];
    [self updateMemDisplay];
    
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
                              [scriptView setFont:CONSOLE_FONT];
                              [scriptView setEditable:NO];
                              [self setFile:[[openPanel URL] path]];
                              [window setTitleWithRepresentedFilename:file];
                          }
                      }];
}

// -----------------------------------------------------------------
// runProg
// Tells the simulator to run the program normally
// -----------------------------------------------------------------
- (IBAction)runProg:(id)sender {
    [simulator runProg];
}

// -----------------------------------------------------------------
// step
// Tells the simulator to step through the next instruction
// -----------------------------------------------------------------
- (IBAction)step:(id)sender {
    [simulator step];
}

// -----------------------------------------------------------------
// trace
// Tells the simulator to trace into the next instruction
// -----------------------------------------------------------------
- (IBAction)trace:(id)sender {
    [simulator trace];
}

// -----------------------------------------------------------------
// pause
// Tells the simulator to pause program execution
// -----------------------------------------------------------------
- (IBAction)pause:(id)sender {
    [simulator pause];
}

// -----------------------------------------------------------------
// rewindProg
// Tells the simulator to rewind the program loaded
// -----------------------------------------------------------------
- (IBAction)rewindProg:(id)sender {
    [simulator rewind];
}

// -----------------------------------------------------------------
// runToCursor
// Tells the simulator to rewind the program loaded
// -----------------------------------------------------------------
- (IBAction)runToCursor:(id)sender {
    // TODO: Get cursor location from listFile, then use this as execute location
    // long runToAddr = [self getAddressFromSelectedLine];
    // [simulator runToCursor:location];
    [simulator runToCursor:0x00000000];
}

// -----------------------------------------------------------------
// reload
// Tells the simulator to reload the program entirely.
// -----------------------------------------------------------------
- (IBAction)reload:(id)sender {
    [simulator loadProgram:[self file]];
}

// -----------------------------------------------------------------
// initListFileView
// initializes the main scroll view with some basic properties
// for viewing listfiles. sets up the line number/breakpoint view
// -----------------------------------------------------------------
- (void)initListfileView {
    const float LargeNumberForText = 1.0e7;

    // Initialize the NSTextView with the NoodleLineNumberView
    lineNumberView = [[[MarkerLineNumberView alloc] initWithScrollView:scrollView] autorelease];
    [scrollView setVerticalRulerView:lineNumberView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
    [scriptView setFont:CONSOLE_FONT];
    [scriptView setEditable:NO];
    
    // Make the scroll view non-wrapping
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    NSTextContainer *textContainer = [scriptView textContainer];
    [textContainer setContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [textContainer setWidthTracksTextView:NO];
    [textContainer setHeightTracksTextView:NO];
    [scriptView setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [scriptView setHorizontallyResizable:YES];
    [scriptView setVerticallyResizable:YES];
    [scriptView setAutoresizingMask:NSViewNotSizable];
    
    //
}

// -----------------------------------------------------------------
// initMemoryScrollers
// initializes the synchronized memory scroll views
// -----------------------------------------------------------------
- (void)initMemoryScrollers {
    [memAddressScroll stopSynchronizing];
    [memAddressScroll setPartnerA:memValueScroll];
    [memAddressScroll setPartnerB:memContentsScroll];
    [memValueScroll stopSynchronizing];
    [memValueScroll setPartnerA:memAddressScroll];
    [memValueScroll setPartnerB:memContentsScroll];
    [memContentsScroll stopSynchronizing];
    [memContentsScroll setPartnerA:memAddressScroll];
    [memContentsScroll setPartnerB:memValueScroll];
}

// -----------------------------------------------------------------
// changeMemLength
// changes the number of bytes the memory display will show
// -----------------------------------------------------------------
- (IBAction)changeMemLength:(id)sender {
    if ([sender isKindOfClass:[NSPopUpButton class]]) {
        NSString *lengthStr = [sender titleOfSelectedItem];
        memDisplayLength = [lengthStr intValue];
        [self updateMemDisplay];
    }
}

// -----------------------------------------------------------------
// memDisplayStart
// gets the starting address for memory display
// -----------------------------------------------------------------
-(unsigned int)memDisplayStart {
    return memDisplayStart;
}

// -----------------------------------------------------------------
// setMemDisplayStart
// sets the starting address for memory display and then updates 
// the memory display
// -----------------------------------------------------------------
-(void)setMemDisplayStart:(unsigned int)newStart {
    if (newStart > 0x00FFFFF0) newStart = 0x00FFFFF1;
    if ((newStart & 0x0000000F) > 0) {
        newStart &= (unsigned int)0xFFFFFFF0;
        [self setMemDisplayStart:newStart];
    }
    memDisplayStart = newStart;
    [self updateMemDisplay];
}

// -----------------------------------------------------------------
// memPageChange
// Changes the currently visible memory page
// -----------------------------------------------------------------

// -----------------------------------------------------------------
// updateMemDisplay
// Updates the memory display window 
// -----------------------------------------------------------------
- (void)updateMemDisplay {
    if (!memory) return;
    
    // Clear current contents of memory window
    [memAddressColumn clearText];
    [memContentsColumn clearText];
    [memValueColumn clearText];
    
    // Enforce some bounds
    int memLength = memDisplayStart + memDisplayLength;             
    if (memLength > MEMSIZE) 
        memLength = memDisplayStart + (MEMSIZE - memDisplayStart);
    
    // Loop through requested memory
    for (int i = memDisplayStart; i < memLength; i+=0x10) {
        
        // Print out address
        NSString *address = [NSString stringWithFormat:@"%08X\n",i];
        [memAddressColumn appendString:address
                              withFont:CONSOLE_FONT];
        
        // More bounds checking
        int jMax = 0x10;                                            
        if (i + jMax >= MEMSIZE) jMax = (MEMSIZE - i);
        
        // Loop 16 bytes
        for (int j = 0; j < jMax; j++) {
            unsigned char memByte = memory[i+j];
            // Print out value and character
            NSString *byteStr = [NSString stringWithFormat:@"%02X ",(unsigned int)memByte];
            NSString *charStr = [NSString stringWithFormat:@"%c",memByte];
            if (iscntrl(memByte)) charStr = [NSString stringWithFormat:@"-"];
            [memValueColumn appendString:byteStr
                                withFont:CONSOLE_FONT];
            [memContentsColumn appendString:charStr
                                   withFont:CONSOLE_FONT];
        }
        
        // New lines
        [memValueColumn appendString:[NSString stringWithFormat:@"\n"]
                            withFont:CONSOLE_FONT];
        [memContentsColumn appendString:[NSString stringWithFormat:@"\n"]
                               withFont:CONSOLE_FONT];
    }
    
    

}


@end

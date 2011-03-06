//
//  Simulator.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Simulator.h"
#include "extern.h"

@implementation Simulator

@synthesize A0,A1,A2,A3,A4,A5,A6,A7,D0,D1,D2,D3,D4,D5,D6,D7,
            GUI_SR,GUI_US,GUI_SS,GUI_PC;


// -----------------------------------------------------------------
// init()
// Initialize the default values of the simulator object
// -----------------------------------------------------------------
- (id) init {
    if (self = [super init]) {
        A0 = A1 = A2 = A3 = A4 = A5 = A6 = A7 = 0;
        D0 = D1 = D2 = D3 = D4 = D5 = D6 = D7 = 0;
        GUI_SR = GUI_US = GUI_SS = GUI_PC = 0;
        startPC = 0;
        return self;
    } else {
        return nil;
    }
}

// -----------------------------------------------------------------
// dealloc()
// -----------------------------------------------------------------
- (void) dealloc {
    if (memory) delete [] memory;
    [super dealloc];
}

// -----------------------------------------------------------------
// initSim()
// 
// -----------------------------------------------------------------
- (void) initSim {
    initSim();
}

// -----------------------------------------------------------------
// memFormat()
// Formats and initializes the 68000 memory. Clears it if already 
// initialized.
// -----------------------------------------------------------------
- (void) memFormat {
    if (memory) delete [] memory;
    try {
        memory = new char[MEMSIZE];
        for (int i=0; i<MEMSIZE; i++)
            memory[i] = 0xFF;
    } catch(...) {
        // MARK: ERROR: Output error message.
        exit(1);    // FAIL
    }
}

// -----------------------------------------------------------------
// runLoop()
// Runs the 6800 program loaded into memory
// -----------------------------------------------------------------
- (void) runLoop {
    static BOOL running = NO;
    
    if (!running) {
        running = YES;
        try {
            while (runMode) {
                runprog();
                // Process messages?
            }
        } catch(...) {
            // Unexpected error
        }
    }
    
    running = NO;
    return;
}

// -----------------------------------------------------------------
// loadProgram()
// 
// -----------------------------------------------------------------
- (void) loadProgram:(NSString* )name {
    
    unsigned int result;
    char fName[256];
    char lFile[256];
    
    // Format memory
    for (int i=0; i<MEMSIZE; i++) memory[i] = 0xFF;
    
    // Initialize the Hardware
    // [hardware init]
    
    // Load the S-Record
    sprintf(fName,"%s",[name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!loadSrec(fName)) {
        
        startPC = PC;
        
        // ASSUMES User does not have any paths with .s68 in them for
        // directory names...
        // nsstring pathExtension returns .s68
        // stringByReplacingOccurrencesOfString:withString:options:range:
        // NSStringEnumerationReverse
        
        
    }
    
    //
    
}


@end

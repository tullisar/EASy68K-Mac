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
// init
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
// dealloc
// -----------------------------------------------------------------
- (void) dealloc {
    if (memory) delete [] memory;
    [listFile release];
    [super dealloc];
}

// -----------------------------------------------------------------
// initSim
// 
// -----------------------------------------------------------------
- (void) initSim {
    initSim();
}

// -----------------------------------------------------------------
// memFormat
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
// runLoop
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
// loadProgram
// -----------------------------------------------------------------
- (void) loadProgram:(NSString* )name {
    
    NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
    
    // unsigned int result;
    char fName[256];
    // char lFile[256];
    
    // Format memory
    for (int i=0; i<MEMSIZE; i++) memory[i] = 0xFF;
    
    // Initialize the Hardware
    // [hardware init]
    // memory[[hardware switchAddr]] = 0x00;
    
    // Load the S-Record
    sprintf(fName,"%s",[name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!loadSrec(fName)) {
        
        startPC = PC;
        
        NSMutableString *listFileName;
        [listFileName initWithFormat:@"%@%@",[name stringByDeletingPathExtension],@".l68"];
        listFile = [NSString stringWithContentsOfFile:listFileName
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
        if (listFile) {
            // Loads the listfile into memory
            NSArray *lines = [listFile componentsSeparatedByCharactersInSet:
                              [NSCharacterSet newlineCharacterSet]];
            
            int offsetPC = [[[lines objectAtIndex:0]
                             substringToIndex:7] 
                            intValue];
            
            if ((offsetPC > 0x000000000) && (offsetPC < 0x01000000))
                startPC = PC = offsetPC;
            
            for (int i=0; i<[lines count]; i++) {
                NSString *line = [lines objectAtIndex:i];
                NSRange found = [line rangeOfString:@"*[sim68k]break"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    // if (isInstruction)
                    //     setBreakPoint;
                }
                
                found = [line rangeOfString:@"*[sim68k]bitfield"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    // enable bitfield instructions
                }
            }
        } else {
            // No listfile, source level debugging not available.
            // Spit out error!
        }
    }
}

// Overridden Setters for Registers. This is so when changing
// fields that are bound to a particular value, it will also
// change the corresponding 68000 register in addition to the GUI
// -----------------------------------------------------------------
// setA0
// -----------------------------------------------------------------
- (void)setA0:(unsigned long)value {
    A0 = value;
    A[0] = value;
}

// -----------------------------------------------------------------
// setA1
// -----------------------------------------------------------------
- (void)setA1:(unsigned long)value {
    A1 = value;
    A[1] = value;
}

// -----------------------------------------------------------------
// setA2
// -----------------------------------------------------------------
- (void)setA2:(unsigned long)value {
    A2 = value;
    A[2] = value;
}

// -----------------------------------------------------------------
// setA3
// -----------------------------------------------------------------
- (void)setA3:(unsigned long)value {
    A3 = value;
    A[3] = value;
}

// -----------------------------------------------------------------
// setA4
// -----------------------------------------------------------------
- (void)setA4:(unsigned long)value {
    A4 = value;
    A[4] = value;
}

// -----------------------------------------------------------------
// setA5
// -----------------------------------------------------------------
- (void)setA5:(unsigned long)value {
    A5 = value;
    A[5] = value;
}

// -----------------------------------------------------------------
// setA6
// -----------------------------------------------------------------
- (void)setA6:(unsigned long)value {
    A6 = value;
    A[6] = value;
}

// -----------------------------------------------------------------
// setA7
// -----------------------------------------------------------------
- (void)setA7:(unsigned long)value {
    A7 = value;
    A[7] = value;
}

// -----------------------------------------------------------------
// setD0
// -----------------------------------------------------------------
- (void)setD0:(unsigned long)value {
    D0 = value;
    D[0] = value;
}

// -----------------------------------------------------------------
// setD1
// -----------------------------------------------------------------
- (void)setD1:(unsigned long)value {
    D1 = value;
    D[1] = value;
}

// -----------------------------------------------------------------
// setD2
// -----------------------------------------------------------------
- (void)setD2:(unsigned long)value {
    D2 = value;
    D[2] = value;
}

// -----------------------------------------------------------------
// setD3
// -----------------------------------------------------------------
- (void)setD3:(unsigned long)value {
    D3 = value;
    D[3] = value;
}

// -----------------------------------------------------------------
// setGUI_SR
// -----------------------------------------------------------------
- (void)setGUI_SR:(unsigned short)value {
    GUI_SR = value;
    SR = value;
}

// -----------------------------------------------------------------
// setGUI_US
// -----------------------------------------------------------------
- (void)setGUI_US:(unsigned long)value {
    GUI_US = value;
    A[7] = value;
}

// -----------------------------------------------------------------
// setGUI_SS
// -----------------------------------------------------------------
- (void)setGUI_SS:(unsigned long)value {
    GUI_SS = value;
    A[8] = value;
}

// -----------------------------------------------------------------
// setGUI_PC
// -----------------------------------------------------------------
- (void)setGUI_PC:(unsigned long)value {
    GUI_PC = value;
    PC = value;
}

@end

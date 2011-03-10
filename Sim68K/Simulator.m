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
            GUI_SR,GUI_US,GUI_SS,GUI_PC,GUI_Cycles;
@synthesize listFile;


// -----------------------------------------------------------------
// init
// Initialize the default values of the simulator object
// -----------------------------------------------------------------
- (id) init {
    if (self = [super init]) {
        A0 = A1 = A2 = A3 = A4 = A5 = A6 = A7 = 0;
        D0 = D1 = D2 = D3 = D4 = D5 = D6 = D7 = 0;
        GUI_SR = GUI_US = GUI_SS = GUI_PC = 0;
        GUI_Cycles = 0;
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
    [self memFormat];
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
        // TODO: GUI Error
        NSLog(@"There was an unexpected error when attempting to format the 68000 memory");
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
                if (trace && sstep) [self displayReg];
                runprog();
                // Process messages?
            }
        } catch(...) {
            // Unexpected error
        }
    }
    
    [self displayReg];
    if (stopInstruction || halt)
        [self setGUI_PC:startPC];
    
    running = NO;
    return;
}

// -----------------------------------------------------------------
// loadProgram
// -----------------------------------------------------------------
- (void) loadProgram:(NSString* )name {
    
    NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
    char fName[1024];                                   // Temporary buffer for NSString->C String
                                                        // TODO: Halt Simulator if running
    [self initSim];                                     // Re-initialize simulator in case one was already open
                                                        // TODO: Initialize Hardware
    // Load the S-Record
    sprintf(fName,"%s",[name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!loadSrec(fName)) {
        
        startPC = PC;
        NSString *listFileName = [NSString stringWithFormat:@"%@%@",
                                  [name stringByDeletingPathExtension],
                                  @".l68"];
        NSString *listFileTemp;
        listFileTemp = [NSString stringWithContentsOfFile:listFileName
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
        if (listFileTemp) {
            NSArray *lines = [listFileTemp componentsSeparatedByCharactersInSet:
                              [NSCharacterSet newlineCharacterSet]];
            NSString *lineAddress = [NSString stringWithFormat:@"0x%@",
                                    [[lines objectAtIndex:0] substringToIndex:8]];
            NSScanner *hexScanner = [NSScanner scannerWithString:lineAddress];

            unsigned int offsetPC = 0;
            if (![hexScanner scanHexInt:&offsetPC]) offsetPC = 0;
            if ((offsetPC > 0x000000000) && (offsetPC < 0x01000000))
                startPC = PC = offsetPC;
            
            for (int i=0; i<[lines count]; i++) {
                NSString *line = [lines objectAtIndex:i];
                NSRange found = [line rangeOfString:@"*[sim68k]break"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    // TODO: Set breakpoint at the location found
                    // if (isInstruction)
                    //     setBreakPoint;
                }
                found = [line rangeOfString:@"*[sim68k]bitfield"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    // TODO: Enable bitfield instructions
                }
            }
            
            NSAttributedString *listContainer;
            listContainer = [[[NSAttributedString alloc] initWithString:listFileTemp] autorelease];
            [self setListFile:listContainer];
            
        } else {
            // TODO: GUI Error
            NSLog(@"Unable to locate or load associated listfile. Source level debugging will be unavailable.");
        }
        
        [self displayReg];
        
    } else {
        // TODO: GUI Error
        NSLog(@"Error loading S-Record file");
    }
}

// -----------------------------------------------------------------
// displayReg
// Updates all the GUI registers to match those of the 68000 simulator
// -----------------------------------------------------------------
- (void)displayReg {
    [self setA0:A[0]];
    [self setA1:A[1]];
    [self setA2:A[2]];
    [self setA3:A[3]];
    [self setA4:A[4]];
    [self setA5:A[5]];
    [self setA6:A[6]];
    [self setA7:A[7]];
    [self setD0:D[0]];
    [self setD1:D[1]];
    [self setD2:D[2]];
    [self setD3:D[3]];
    [self setD4:D[4]];
    [self setD5:D[5]];
    [self setD6:D[6]];
    [self setD7:D[7]];
    [self setGUI_US:A[7]];
    [self setGUI_SS:A[8]];
    [self setGUI_PC:PC];
    [self setGUI_SR:SR];
    [self setGUI_Cycles:cycles];
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
// GUI_US
// -----------------------------------------------------------------
- (unsigned long)setGUI_US {
    return A[7];
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

// -----------------------------------------------------------------
// setGUI_Cycles
// -----------------------------------------------------------------
- (void)setGUI_Cycles:(unsigned long long)value {
    GUI_Cycles = value;
    cycles = value;
}


@end

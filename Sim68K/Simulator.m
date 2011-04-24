//
//  Simulator.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Simulator.h"
#import "BreakpointDelegate.h"
#include "extern.h"

@implementation Simulator

@synthesize A0,A1,A2,A3,A4,A5,A6,A7,D0,D1,D2,D3,D4,D5,D6,D7,
            GUI_SR,GUI_US,GUI_SS,GUI_PC,GUI_Cycles,startPC;
@synthesize listFile,listFileLines,simLoaded,simStopped,simInputMode;


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
        [self setSimLoaded:NO];
        [self setSimStopped:YES];
        [self setSimInputMode:NO];
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
    [self displayReg];
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
                runprog();
                // Process messages?
            }
        } catch(...) {
            // Unexpected error
        }
        [self setSimStopped:YES];
    }
    
    if (stopInstruction || halt)
        PC = startPC;
    [self displayReg];
    
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
        
        startPC = OLD_PC = PC;
        NSString *listFileName = [NSString stringWithFormat:@"%@%@",
                                  [name stringByDeletingPathExtension],
                                  @".l68"];
        NSString *listFileTemp;
        listFileTemp = [NSString stringWithContentsOfFile:listFileName
                                             encoding:NSUTF8StringEncoding
                                                error:NULL];
        if (listFileTemp) {
            listFileLines = [listFileTemp componentsSeparatedByCharactersInSet:             // Load array of lines in listfile
                             [NSCharacterSet newlineCharacterSet]];
            NSString *lineAddress = [NSString stringWithFormat:@"0x%@",
                                    [[listFileLines objectAtIndex:0] substringToIndex:8]];
            NSScanner *hexScanner = [NSScanner scannerWithString:lineAddress];

            unsigned int offsetPC = 0;
            if (![hexScanner scanHexInt:&offsetPC]) offsetPC = 0;
            if ((offsetPC > 0x000000000) && (offsetPC < 0x01000000))
                startPC = PC = offsetPC;
            
            for (int i=0; i<[listFileLines count]; i++) {
                NSString *line = [listFileLines objectAtIndex:i];
                NSRange found = [line rangeOfString:@"*[sim68k]break"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    if (i+1 > 2 && [self isInstruction:line]) {
                        lineAddress = [NSString stringWithFormat:@"0x%@",
                                       [[listFileLines objectAtIndex:i] substringToIndex:8]];
                        NSNumber *addrVal = [lineAddress unsignedHexValue];
                        [BreakpointDelegate sbpoint:[addrVal unsignedIntValue]];
                    }
                }
                found = [line rangeOfString:@"*[sim68k]bitfield"];
                if (!NSEqualRanges(found, notFoundRange)) {
                    bitfield = true;
                }
            }
            
            NSAttributedString *listContainer;
        
            listContainer = [[[NSAttributedString alloc] initWithString:listFileTemp] autorelease];
            [self setListFile:listContainer];
            
        } else {
            // TODO: GUI Error
            NSLog(@"Unable to locate or load associated listfile. Source level debugging will be unavailable.");
        }
        
        [self setSimLoaded:YES];
        [self setSimStopped:YES];
        [self displayReg];
        [appDelegate updateMemDisplay];
        
    } else {
        // TODO: GUI Error
        [self setSimLoaded:NO];
        NSLog(@"Error loading S-Record file.");
    }
}

// -----------------------------------------------------------------
// displayReg
// Updates all the GUI registers to match those of the 68000 simulator
// -----------------------------------------------------------------
- (void)displayReg {
    // FIXME: This still isn't thread-safe. The setters could get pre-empted.
    DISPATCH_MAIN_THREAD
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
//     [self setMemoryContents:[[[NSTextStorage alloc] initWithString:@""] autorelease]];
}

// -----------------------------------------------------------------
// runProg
// Initiates the program run loop after disabling tracing and steps
// -----------------------------------------------------------------
- (void)runProg {
    if (simLoaded) {
        trace       = false;
        sstep       = false;
        runMode     = true;
        runModeSave = runMode;
        // MARK: HARDWARE: Enable Auto-IRQ
        // MARK: I/O: Bring I/O front
        // TODO: Run runLoop in a thread so that it doesn't hog the GUI
        // [self runLoop];
        // [self performSelectorInBackground:@sel(@"runLoop:") withObject:nil];
        [self setSimStopped:NO];
        NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
        NSOperation *simLoop = [[[NSInvocationOperation alloc] 
                                 initWithTarget:self
                                 selector:@selector(runLoop)
                                 object:nil] autorelease];
        [queue addOperation:simLoop];
    }
}

// -----------------------------------------------------------------
// step
// Steps through the next instruction
// -----------------------------------------------------------------
- (void)step {
    if (simLoaded) {
        trace       = true;
        sstep       = true;
        stepToAddr  = 0;
        runMode     = true;
        runModeSave = runMode;
        [self runLoop];
    }
}

// -----------------------------------------------------------------
// trace
// Traces into the next instruction
// -----------------------------------------------------------------
- (void)trace {
    if (simLoaded) {
        trace       = true;
        sstep       = false;
        runprog();
        [self displayReg];
    }
}

// -----------------------------------------------------------------
// pause
// Pauses program execution
// -----------------------------------------------------------------
- (void)pause {
    if (simLoaded) {
        trace       = true;
        sstep       = false;
        runMode     = false;
        if (inputMode)
            inputMode = false;
        [self displayReg];
        // TODO: Disable auto-trace timer
        // MARK: HARDWARE: Disable auto IRQ
    }
}

// -----------------------------------------------------------------
// rewindProg
// Rewinds the loaded program
// -----------------------------------------------------------------
- (void)rewind {
    // TODO: Disable auto-trace timer
    PC = [self startPC];
    initSim();
    [self displayReg];
    OLD_PC = PC;
}

// -----------------------------------------------------------------
// runToCursor
// Tells the simulator to rewind the program loaded
// -----------------------------------------------------------------
- (void)runToCursor:(long)location {
    // MARK: DEBUG: Must set during debug, as it'll always be zero for now.
    location = 0x00000000;
    runToAddr = location;
}

// -----------------------------------------------------------------
// isInstruction
// Determines whether the given listfile line contains a 68000 instruction
// -----------------------------------------------------------------
- (BOOL)isInstruction:(NSString *)line {
    const char *cString = [line cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (strlen(cString) < 12) return NO;
    
    if ((cString[0]  == '0' && cString[1] == '0') &&
         cString[10] != ' ' &&
         cString[8]  != '=' &&
         cString[10] != '=')
        return YES;
    return NO;
}

// -----------------------------------------------------------------
// memoryContents
// -----------------------------------------------------------------
- (NSTextStorage *)memoryContents {
//
//    
//    if (memory && simLoaded && NO) {
//        NSMutableString *text   = [[NSMutableString alloc] initWithString:@""];
//
//        for (int i = 0; i < MEMSIZE; i++) {
//            for (int j = 0; j < 0x10; j++) {
//                unsigned char memByte = memory[i++];
//                [text appendFormat:@"%02X ", memByte];
//            }
//            [text appendFormat:@"%@",@"\n"];
//        }
//        
//        NSTextStorage *contents = [[NSTextStorage alloc] initWithString:text];
//        NSRange memLength = NSMakeRange(0, [text length]);
//        
//        [contents addAttribute:NSFontAttributeName value:CONSOLE_FONT range:memLength];
//        
//        return contents;
//    }
//
//    return [[[NSTextStorage alloc] initWithString:@"Memory not initialized."] autorelease];
}

// -----------------------------------------------------------------
// setMemoryContents
// -----------------------------------------------------------------
- (void)setMemoryContents:(NSTextStorage *)contents {
//    
//    NSMutableString *memBlock = [contents mutableString];
//    NSString *memBlockTrimmed = [memBlock stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    memBlockTrimmed = [memBlockTrimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    NSArray *components = [memBlockTrimmed componentsSeparatedByCharactersInSet:
//                           [NSCharacterSet whitespaceCharacterSet]];
//    
//    int a = 0;
    
}

// ------------------------------------------------------------------------------------------------------------------------------
// Overridden Setters for Registers. This is so when changing
// fields that are bound to a particular value, it will also
// change the corresponding 68000 register in addition to the GUI
// -----------------------------------------------------------------
// setA0
// -----------------------------------------------------------------
- (void)setA0:(long)value {        
    A0 = value;
    A[0] = value;
}

// -----------------------------------------------------------------
// setA1
// -----------------------------------------------------------------
- (void)setA1:(long)value {
    A1 = value;
    A[1] = value;
}

// -----------------------------------------------------------------
// setA2
// -----------------------------------------------------------------
- (void)setA2:(long)value {
    A2 = value;
    A[2] = value;
}

// -----------------------------------------------------------------
// setA3
// -----------------------------------------------------------------
- (void)setA3:(long)value {
    A3 = value;
    A[3] = value;
}

// -----------------------------------------------------------------
// setA4
// -----------------------------------------------------------------
- (void)setA4:(long)value {
    A4 = value;
    A[4] = value;
}

// -----------------------------------------------------------------
// setA5
// -----------------------------------------------------------------
- (void)setA5:(long)value {
    A5 = value;
    A[5] = value;
}

// -----------------------------------------------------------------
// setA6
// -----------------------------------------------------------------
- (void)setA6:(long)value {
    A6 = value;
    A[6] = value;
}

// -----------------------------------------------------------------
// setA7
// -----------------------------------------------------------------
- (void)setA7:(long)value {
    A7 = value;
    A[7] = value;
}

// -----------------------------------------------------------------
// setD0
// -----------------------------------------------------------------
- (void)setD0:(long)value {
    D0 = value;
    D[0] = value;
}

// -----------------------------------------------------------------
// setD1
// -----------------------------------------------------------------
- (void)setD1:(long)value {
    D1 = value;
    D[1] = value;
}

// -----------------------------------------------------------------
// setD2
// -----------------------------------------------------------------
- (void)setD2:(long)value {
    D2 = value;
    D[2] = value;
}

// -----------------------------------------------------------------
// setD3
// -----------------------------------------------------------------
- (void)setD3:(long)value {
    D3 = value;
    D[3] = value;
}

// -----------------------------------------------------------------
// setD4
// -----------------------------------------------------------------
- (void)setD4:(long)value {
    D4 = value;
    D[4] = value;
}

// -----------------------------------------------------------------
// setD5
// -----------------------------------------------------------------
- (void)setD5:(long)value {
    D5 = value;
    D[5] = value;
}

// -----------------------------------------------------------------
// setD6
// -----------------------------------------------------------------
- (void)setD6:(long)value {
    D6 = value;
    D[6] = value;
}

// -----------------------------------------------------------------
// setD7
// -----------------------------------------------------------------
- (void)setD7:(long)value {
    D7 = value;
    D[7] = value;
}

// -----------------------------------------------------------------
// setGUI_SR
// -----------------------------------------------------------------
- (void)setGUI_SR:(short)value {
    GUI_SR = value;
    SR = value;
}

// -----------------------------------------------------------------
// setGUI_US
// -----------------------------------------------------------------
- (void)setGUI_US:(long)value {
    GUI_US = value;
    A[7] = value;
}

// -----------------------------------------------------------------
// GUI_US
// -----------------------------------------------------------------
- (long)setGUI_US {
    return A[7];
}

// -----------------------------------------------------------------
// setGUI_SS
// -----------------------------------------------------------------
- (void)setGUI_SS:(long)value {
    GUI_SS = value;
    A[8] = value;
}

// -----------------------------------------------------------------
// setGUI_PC
// -----------------------------------------------------------------
- (void)setGUI_PC:(long)value {
    GUI_PC = value;
    PC = value;
}

// -----------------------------------------------------------------
// setGUI_Cycles
// -----------------------------------------------------------------
- (void)setGUI_Cycles:(unsigned long int)value {
    GUI_Cycles = value;
    // cycles = value;
}

@end

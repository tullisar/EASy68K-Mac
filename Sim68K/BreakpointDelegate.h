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
    
    // Generic value populators
    NSArray         *sizeStrings;
    NSString        *errString;
    BOOL            breakError;
    
    // PC & Register Breakpoints
    IBOutlet NSTextView *regBPList;
    NSMutableArray  *regBreakpoints;
    NSArray         *regOpStrings;
    NSArray         *validRegList;
    int             selRegBP;
    int             selReg;
    int             selRegOp;
    long            selRegValue;
    int             selRegSize;
    
    // Memory (Address) Breakpoints
    IBOutlet NSTextView *memBPList;
    NSMutableArray  *memBreakpoints;
    NSArray         *memOpStrings;
    NSArray         *memRWStrings;
    int             selMemBP;
    long            selMemAddr;
    int             selMemOp;
    long            selMemValue;
    int             selMemSize;
    int             selMemAccess;
    
    // Breakpoint Expressions
    
}

// Generics
@property (retain) NSArray  *sizeStrings;
@property (retain) NSString *errString;
@property (assign) BOOL     breakError;

// PC & Reg
@property (retain) NSMutableArray *regBreakpoints;
@property (retain) NSArray *regOpStrings;
@property (retain) NSArray *validRegList;
@property (assign) int     selRegBP;
@property (assign) int     selReg;
@property (assign) int     selRegOp;
@property (assign) long    selRegValue;
@property (assign) int     selRegSize;

// Memory
@property (retain) NSMutableArray *memBreakpoints;
@property (retain) NSArray *memOpStrings;
@property (retain) NSArray *memRWStrings;
@property (assign) int     selMemBP;
@property (assign) long    selMemAddr;
@property (assign) int     selMemOp;
@property (assign) long    selMemValue;
@property (assign) int     selMemSize;
@property (assign) int     selMemAccess;

// Expressions

// Functions
+ (int)sbpoint:(int)loc;
+ (int)cbpoint:(int)loc;
- (IBAction)setRegBP:(id)sender;
- (IBAction)clearRegBP:(id)sender;
- (IBAction)clearAllRegBP:(id)sender;
- (void)updateRegBPList;
- (IBAction)setMemBP:(id)sender;
- (IBAction)clearMemBP:(id)sender;
- (IBAction)clearAllMemBP:(id)sender;
- (void)updateMemBPList;

@end

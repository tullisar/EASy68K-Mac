/***************************** 68000 SIMULATOR ****************************
 
 File Name: BreakpointDelegate.m
 Version: 1.0 (Mac OS X)
 
 Implementation file for the breakpoint delegate that handles setting of
 68K breakpoints. This will eventually be used to handle advanced breakpoints
 by being a data source for the table view that handles advanced breakpoints.
 
 Created:  2011-04-15
 Robert Bartlett-Schneider
 
 ***************************************************************************/

#import "BreakpointDelegate.h"
#include "extern.h"

@implementation BreakpointDelegate

@synthesize sizeStrings, errString, breakError;
@synthesize regBreakpoints, regOpStrings, validRegList, selRegBP, selReg, selRegOp, selRegValue, selRegSize;
@synthesize memBreakpoints, memOpStrings, memRWStrings, selMemBP, selMemAddr, selMemOp, selMemValue, selMemSize, selMemAccess;
@synthesize exprBreakpoints, regBPLabels, memBPLabels, selExprBP, selExprBPEnabled, selExprString, selExprCount;
@synthesize exprSet, exprClear, exprClearAll, exprAnd, exprOr, exprLParen, exprRParen, exprBack, exprReg, exprMem;

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

// -----------------------------------------------------------------
// awakeFromNib
// Runs when the NIB file has been loaded.
// -----------------------------------------------------------------
- (void)awakeFromNib {    
    const float LargeNumberForText = 1.0e7;
    
    // Initialize size combo-box values & other window generic stuff
    [self setSizeStrings:
     [NSArray arrayWithObjects:@"Byte", @"Word", @"Long", nil]];
    [self setErrString:@""];
    [self setBreakError:NO];
    
    // Initialize controls for PC/Register breakpoints
    [self setRegBreakpoints:[NSMutableArray arrayWithCapacity:(MAX_BPOINTS)/2+1]];
    [self updateRegBPList];
    [self setRegOpStrings:
     [NSArray arrayWithObjects:@"==", @"!=", @">", @">=", @"<", @"<=", nil]];
    [self setValidRegList:
     [NSArray arrayWithObjects:@"D0", @"D1", @"D2", @"D3", @"D4", @"D5", @"D6", @"D7", 
      @"A0", @"A1", @"A2", @"A3", @"A4", @"A5", @"A6", @"A7", @"PC", nil]];
    [self setSelReg:0];
    [self setSelRegOp:0];
    [self setSelRegValue:0x00000000];
    [self setSelRegSize:0];
    
    // Initialize controls for Address breakpoints
    [self setMemBreakpoints:[NSMutableArray arrayWithCapacity:(MAX_BPOINTS)/2+1]];
    [self updateMemBPList];
    [self setMemOpStrings:
     [NSArray arrayWithObjects:@"==", @"!=", @">", @">=", @"<", @"<=", @"N/A", nil]];
    [self setMemRWStrings:
     [NSArray arrayWithObjects:@"R/W", @"R", @"W", @"N/A", nil]];
    [self setSelMemAddr:0x00000000];
    [self setSelMemOp:0];
    [self setSelMemValue:0x00000000];
    [self setSelMemSize:0];
    [self setSelMemAccess:0];
    
    // Initialize controls for Breakpoint expressions
    [self setExprBreakpoints:[NSMutableArray arrayWithCapacity:MAX_BPOINTS]];
    [self setMemBPLabels:[NSMutableArray arrayWithCapacity:(MAX_BPOINTS)/2]];
    [self setRegBPLabels:[NSMutableArray arrayWithCapacity:(MAX_BPOINTS)/2]];
    [self updateExprBPList];
    [self setSelExprBP:0];
    [self setSelExprBPEnabled:false];
    [self setSelExprString:@""];
    [self setSelExprCount:0];
    
    // Make expression scroll view non wrapping
    [exprScroller setHasVerticalScroller:YES];
    [exprScroller setHasHorizontalScroller:YES];
    [exprScroller setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    NSTextContainer *textContainer = [exprBPList textContainer];
    [textContainer setContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [textContainer setWidthTracksTextView:NO];
    [textContainer setHeightTracksTextView:NO];
    [exprBPList setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [exprBPList setHorizontallyResizable:YES];
    [exprBPList setVerticallyResizable:YES];
    [exprBPList setAutoresizingMask:NSViewNotSizable]; 
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// changeRegBP
// Update fields when selection is changed
// -----------------------------------------------------------------
- (IBAction)changeRegBP:(id)sender {
 
    int selection;
    BPoint *curBPoint;
    
    if ([sender isKindOfClass:[NSNumber class]]) {
        selection = [(NSNumber*)sender intValue];
    } else {
        selection = [(NSPopUpButton*)sender indexOfSelectedItem];
    }
    
    if (selection <= regCount) {
        curBPoint = &breakPoints[selection-1];
        [self setSelReg:curBPoint->getTypeId()];
        [self setSelRegOp:curBPoint->getOperator()];
        [self setSelRegValue:curBPoint->getValue()];
        [self setSelRegSize:curBPoint->getSize()];
    } else if (selection == 0 || selection > regCount) {
        [self setSelReg:0];
        [self setSelRegOp:0];
        [self setSelRegValue:0x00000000];
        [self setSelRegSize:0];
    }
}

// -----------------------------------------------------------------
// setRegBP
// Sets a PC / Register breakpoint
// -----------------------------------------------------------------
- (IBAction)setRegBP:(id)sender {
    
    int selection = [self selRegBP];
    if (selection < 1) return;
    
    // Set the register breakpoint using currently selected information
    BPoint *curBPoint = &breakPoints[selection-1];
    curBPoint->setId(regCount);
    curBPoint->setType(PC_REG_TYPE);
    curBPoint->setTypeId([self selReg]);
    curBPoint->setOperator([self selRegOp]);
    curBPoint->setValue([self selRegValue]);
    curBPoint->setSize([self selRegSize]);
    curBPoint->isEnabled(true);
    
    if (selection > regCount) {
        regCount++;
        selection++;
    }
    
    [self updateRegBPList];
    [self setSelRegBP:selection];
}

// -----------------------------------------------------------------
// clearRegBP
// Clears a PC / Register breakpoint
// -----------------------------------------------------------------
- (IBAction)clearRegBP:(id)sender {
    
    int selection = [self selRegBP];
    if (selection < 1 || selection > regCount) return;

    // Shift the elements in the breakPoints array and decrement the count.
    BPoint *temp = &breakPoints[selection-1];
    for(int curRow = selection; curRow < regCount; curRow++) {
        breakPoints[curRow - 1] = breakPoints[curRow];
    }
    regCount--;
    breakPoints[regCount] = *temp;
    breakPoints[regCount].isEnabled(false);
    
    [self updateRegBPList];
    if ((selection > regCount) && (selection > 1)) selection = regCount;
    [self setSelRegBP:selection];
    [self changeRegBP:[NSNumber numberWithInt:selection]];
}

// -----------------------------------------------------------------
// clearAllRegBP
// Clears all pc/register breakpoints
// -----------------------------------------------------------------
- (IBAction)clearAllRegBP:(id)sender {
    
    // Invalidate all memory breakpoints
    for(int cur = 0; cur < regCount; cur++)
        breakPoints[cur].isEnabled(false);
    regCount = 0;
    
    // Update display
    [self updateRegBPList];
    [self setSelRegBP:1];
    [self changeRegBP:[NSNumber numberWithInt:1]];
}

// -----------------------------------------------------------------
// updateRegBPList
// Updates the list of pc/register breakpoints
// -----------------------------------------------------------------
- (void)updateRegBPList {
    
    NSMutableArray  *worker, *exprChoices;
    NSString        *line, *textLine;
    NSString        *breakNum, *type, *op, *rVal, *size;
    NSString        *numSpacer, *opSpacer;
    NSTextStorage   *textStore;
    BPoint          *curBPoint;
    NSRange         textRange;
    NSDictionary    *textAttr;
    
    // Reset the list of options and regenerate
    worker      = [self regBreakpoints];
    exprChoices = [self regBPLabels];
    [worker removeAllObjects];
    [exprChoices removeAllObjects];
    [regBPList clearText];
    [regBPList appendString:@"     Reg Op Value      Size\n"];                     // Header column for text view
    [worker addObject:@"Select Register Breakpoint"];                              // Instructions
    for (int i = 1; i <= regCount; i++) {
        
        curBPoint = &breakPoints[i-1];
        breakNum = [NSString stringWithFormat:@"%d",i];                            // Breakpoint Index
        if (i < 10) numSpacer = @" ";                                              // Spacer when single digit index
        else numSpacer = @"";
        type     = [[self validRegList] objectAtIndex:(curBPoint->getTypeId())];   // PC/Reg Num
        op       = [[self regOpStrings] objectAtIndex:(curBPoint->getOperator())]; // Operator
        if ([op length] < 2) opSpacer = @" ";                                      // Spacer when short operator
        else opSpacer = @"";
        rVal     = [NSString stringWithFormat:@"0x%08X",curBPoint->getValue()];    // Value
        size     = [[self sizeStrings] objectAtIndex:(curBPoint->getSize())];      // Size
        
        line = [NSString stringWithFormat:@"%@%@ %@ %@ %@ (%@)",                   // Format becomes
                breakNum, numSpacer, type, op, rVal, size];                        // ## R# == 0x00000000 (Size)
        [worker addObject:line];
        [exprChoices addObject:line];
        textLine = [NSString stringWithFormat:@"(%@)%@ %@  %@%@ %@ (%@)",          // Format becomes
                    breakNum, numSpacer, type, op, opSpacer, rVal, size];          // (##) R# == 0x00000000 (Size)
        [regBPList appendString:textLine];
        [regBPList appendString:@"\n"];
    }
    
    // Placeholder for new breakpoint
    if (regCount < (MAX_BPOINTS/2)) {
        line = [NSString stringWithFormat:@"%d New PC / Register breakpoint...",regCount+1];
        [worker addObject:line];
    }
    
    // Ensure font & color are correct for HUD window text
    textStore = [regBPList textStorage];
    textRange = NSMakeRange(0, [textStore length]);
    textAttr  = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSColor whiteColor], NSForegroundColorAttributeName,
                 [NSFont fontWithName:@"Courier" size:10], NSFontAttributeName, nil];
    [textStore setAttributes:textAttr range:textRange];
    
    // Update the mutable array binding
    [self setRegBreakpoints:worker];
    [self setRegBPLabels:exprChoices];
}

// -----------------------------------------------------------------
// changeMemBP
// Update fields when selection is changed
// -----------------------------------------------------------------
- (IBAction)changeMemBP:(id)sender {
    
    int selection;
    BPoint *curBPoint;
    
    if ([sender isKindOfClass:[NSNumber class]]) {
        selection = [(NSNumber*)sender intValue];
    } else {
        selection = [(NSPopUpButton*)sender indexOfSelectedItem];
    }
    
    if (selection <= addrCount) {
        curBPoint = &breakPoints[selection-1+ADDR_ID_OFFSET];
        [self setSelMemAddr:curBPoint->getTypeId()];
        [self setSelMemOp:curBPoint->getOperator()];
        [self setSelMemValue:curBPoint->getValue()];
        [self setSelMemSize:curBPoint->getSize()];
        [self setSelMemAccess:curBPoint->getReadWrite()];
    } else if (selection == 0 || selection > addrCount) {
        [self setSelMemAddr:0x00000000];
        [self setSelMemOp:0];
        [self setSelMemValue:0x00000000];
        [self setSelMemSize:0];
        [self setSelMemAccess:0];        
    }
    
}


// -----------------------------------------------------------------
// setMemBP
// Sets a Memory address breakpoint
// -----------------------------------------------------------------
- (IBAction)setMemBP:(id)sender {
    
    int selection = [self selMemBP];
    if (selection < 1) return;
    
    // Set the register breakpoint using currently selected information
    BPoint *curBPoint = &breakPoints[selection-1 + ADDR_ID_OFFSET];
    curBPoint->setId(addrCount);
    curBPoint->setType(ADDR_TYPE);
    curBPoint->setTypeId([self selMemAddr]);
    curBPoint->setOperator([self selMemOp]);
    curBPoint->setValue([self selMemValue]);
    curBPoint->setSize([self selMemSize]);
    curBPoint->setReadWrite([self selMemAccess]);
    curBPoint->isEnabled(true);
    
    if (selection > addrCount) {
        addrCount++;
        selection++;
    }
    
    [self updateMemBPList];
    [self setSelMemBP:selection];
}

// -----------------------------------------------------------------
// clearMemBP
// Clears a Memory address breakpoint
// -----------------------------------------------------------------
- (IBAction)clearMemBP:(id)sender {
    
    int selection = [self selMemBP];
    if (selection < 1 || selection > addrCount) return;
    
    // Shift the elements in the breakPoints array and decrement the count.
    BPoint *temp = &breakPoints[selection-1 + ADDR_ID_OFFSET];
    for(int curRow = selection; curRow < addrCount; curRow++) {
        breakPoints[curRow - 1 + ADDR_ID_OFFSET] = breakPoints[curRow + ADDR_ID_OFFSET];
    }
    addrCount--;
    breakPoints[addrCount + ADDR_ID_OFFSET] = *temp;
    breakPoints[addrCount + ADDR_ID_OFFSET].isEnabled(false);
    
    [self updateMemBPList];
    if ((selection > addrCount) && (selection > 1)) selection = addrCount;
    [self setSelMemBP:selection];
    [self changeMemBP:[NSNumber numberWithInt:selection]];
    
}

// -----------------------------------------------------------------
// clearAllMemBP
// Clears all memory breakpoints
// -----------------------------------------------------------------
- (IBAction)clearAllMemBP:(id)sender {
    
    // Invalidate all memory breakpoints
    for(int cur = ADDR_ID_OFFSET; cur < (ADDR_ID_OFFSET+addrCount); cur++)
        breakPoints[cur].isEnabled(false);
    addrCount = 0;
    
    // Update display
    [self updateMemBPList];
    [self setSelMemBP:1];
    [self changeMemBP:[NSNumber numberWithInt:1]];    
}

// -----------------------------------------------------------------
// updateMemBPList
// Updates the list of memory address breakpoints
// -----------------------------------------------------------------
- (void)updateMemBPList {
    
    NSMutableArray  *worker, *exprChoices;
    NSString        *line, *textLine;
    NSString        *breakNum, *address, *op, *aVal, *size, *access;
    NSString        *numSpacer, *opSpacer;
    NSTextStorage   *textStore;
    BPoint          *curBPoint;
    NSRange         textRange;
    NSDictionary    *textAttr;
    
    // Reset the list of options and regenerate
    worker      = [self memBreakpoints];
    exprChoices = [self memBPLabels];
    [worker removeAllObjects];
    [exprChoices removeAllObjects];
    [memBPList clearText];
    [memBPList appendString:@"     Addr       Op Value      Size   Type\n"];         // Header column for text view
                            //(50) 0x00000000 == 0x00000000 (Long) R/W
    [worker addObject:@"Select Memory Address Breakpoint"];                          // Instructions....
    for (int i = 1; i <= addrCount; i++) {
        
        curBPoint = &breakPoints[i-1+ADDR_ID_OFFSET];
        breakNum = [NSString stringWithFormat:@"%d",i];                              // Breakpoint Index
        if (i < 10) numSpacer = @" ";                                                // Spacer when single digit index
        else numSpacer = @"";
        address  = [NSString stringWithFormat:@"0x%08X",curBPoint->getTypeId()];     // Address
        op       = [[self regOpStrings] objectAtIndex:(curBPoint->getOperator())];   // Operator
        if ([op length] < 2) opSpacer = @" ";                                        // Spacer when short operator
        else opSpacer = @"";
        aVal     = [NSString stringWithFormat:@"0x%08X",curBPoint->getValue()];      // Value
        size     = [[self sizeStrings] objectAtIndex:(curBPoint->getSize())];        // Size 
        access   = [[self memRWStrings] objectAtIndex:(curBPoint->getReadWrite())];  // Read/Write

        line = [NSString stringWithFormat:@"%@%@ %@ %@ %@ (%@) %@",                  // Format becomes
                breakNum, numSpacer, address, op, aVal, size, access];               // ## 0x00000000 == 0x00000000 (Size) R/W
        [worker addObject:line];
        [exprChoices addObject:line];
        textLine = [NSString stringWithFormat:@"(%@)%@ %@ %@%@ %@ (%@) %@",          // Format becomes
                    breakNum, numSpacer, address, op, opSpacer, aVal, size, access]; // (##) 0x00000000 == 0x00000000 (Size) R/W
        [memBPList appendString:textLine];
        [memBPList appendString:@"\n"];        

    }
    
    // Placeholder for new breakpoint
    if (addrCount < (MAX_BPOINTS/2)) {
        line = [NSString stringWithFormat:@"%d New Memory address breakpoint...",addrCount+1];
        [worker addObject:line];
    }
    
    // Ensure font & color are correct for HUD window text
    textStore = [memBPList textStorage];
    textRange = NSMakeRange(0, [textStore length]);
    textAttr  = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSColor whiteColor], NSForegroundColorAttributeName,
                 [NSFont fontWithName:@"Courier" size:10], NSFontAttributeName, nil];
    [textStore setAttributes:textAttr range:textRange];
    
    // Update the mutable array binding
    [self setMemBreakpoints:worker];
    [self setMemBPLabels:exprChoices];
}

// -----------------------------------------------------------------
// changeExprBP
// Update fields when selection is changed
// -----------------------------------------------------------------
- (IBAction)changeExprBP:(id)sender {
    
    int selection;
    BPointExpr *curBPoint;
    
    if ([sender isKindOfClass:[NSNumber class]]) {
        selection = [(NSNumber*)sender intValue];
    } else {
        selection = [(NSPopUpButton*)sender indexOfSelectedItem];
    }
    
    if (selection <= exprCount) {
        curBPoint = &bpExpressions[selection-1];
        [self setSelExprString:curBPoint->getExprString()];
        [self setSelExprBPEnabled:curBPoint->isEnabled()];
        [self setSelExprCount:curBPoint->getCount()];
        
        // Reset the expression array elements, so a new expression can be constructed.
        for(int i = 0; i < MAX_LB_NODES; i++) {
            infixExpr[i] = -1;
        }
        
        // Since an expression has already begun to be built,
        // reload the expression to allow for continued editing options.
        bpExpressions[selection-1].getInfixExpr(infixExpr, infixCount);
        parenCount = 0;
        if(infixExpr[infixCount-1] != RPAREN)
            mruOperand = true;
        else
            mruOperand = false;
        mruOperator = false;
        
    } else if (selection == 0 || selection > exprCount) {
        [self setSelExprString:@""];
        [self setSelExprBPEnabled:false];
        [self setSelExprCount:0];
        
        // Reset the expression array elements, so a new expression can be constructed.
        for(int i = 0; i < MAX_LB_NODES; i++) {
            infixExpr[i] = -1;
        }
        infixCount = 0;
        parenCount = 0;
        mruOperand = false;
        mruOperator = false;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// setExprBP
// Sets an expression breakpoint
// -----------------------------------------------------------------
- (IBAction)setExprBP:(id)sender {

    // Initialize current bpExpression element
    int selection = [self selExprBP];
    if (selection < 1) return;
    
    bpExpressions[selection-1].setId(selection);
    bpExpressions[selection-1].isEnabled([self selExprBPEnabled]);
    bpExpressions[selection-1].setExprString([self selExprString]);
    bpExpressions[selection-1].setCount([self selExprCount]);
    bpExpressions[selection-1].setInfixExpr(infixExpr, infixCount);  
    
    // Convert infix expression to binary expression tree.
    int curToken = 0;
    int stackToken;
    postfixCount = 0;
    
    for(int tok = 0; tok < infixCount; tok++) {
        curToken = infixExpr[tok];
        switch(curToken) {
            case MAX_BPOINTS + AND_OP:
            case MAX_BPOINTS + OR_OP:
                while(!s_operator.empty() &&
                      ((stackToken = s_operator.top()) != LPAREN) &&
                      ([self precedence:curToken] <= [self precedence:stackToken])){
                    postfixExpr[postfixCount++] = stackToken;
                    s_operator.pop();
                };
                s_operator.push(curToken);
                break;
            case LPAREN:
                s_operator.push(curToken);
                break;
            case RPAREN:
                while((stackToken = s_operator.top()) != LPAREN) {
                    postfixExpr[postfixCount++] = stackToken;
                    s_operator.pop();
                };
                break;
            default:     // if the token is an operand ...
                postfixExpr[postfixCount++] = curToken;
                break;
        }
    }
    
    while(!s_operator.empty()) {
        stackToken = s_operator.top();
        if(stackToken != LPAREN)
            postfixExpr[postfixCount++] = stackToken;
        s_operator.pop();
    };
    
    bpExpressions[selection-1].setPostfixExpr(postfixExpr, postfixCount);
    infixCount = 0;
    parenCount = 0;
    mruOperand = false;
    mruOperator = false;
    
    if (selection > exprCount) {
        exprCount++;
        selection++;
    }
    
    [self updateExprBPList];
    [self setSelExprBP:selection];
    [self changeExprBP:[NSNumber numberWithInt:selection]];
}

// -----------------------------------------------------------------
// precedence
// Currently this is a trivial operation.  The highest precedence
// operator (AND) has the lowest integer value.  For readability in
// the infix to postfix conversion algorithm, the precedence function
// is used to reverse the logic.
// -----------------------------------------------------------------
- (int)precedence:(int)op_prec {
    return -op_prec;
}

// -----------------------------------------------------------------
// exprRegAppend
// Append a chosen register breakpoint from the list
// -----------------------------------------------------------------
- (IBAction)exprRegAppend:(id)sender {
 
    NSPopUpButton   *selectBox = (NSPopUpButton *)sender;
    NSString        *original;
    NSMutableString *newExpr;
    int             regIndex;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        original = [self selExprString];
        regIndex = [selectBox indexOfSelectedItem]+1;
        if(regIndex > 0 && regIndex <= regCount) {
            infixExpr[infixCount++] = regIndex - 1;
            newExpr = [NSMutableString stringWithString:original];
            [newExpr appendFormat:@" R%d",regIndex];
            if(regIndex < 10) [newExpr appendString:@" "];
            [newExpr appendString:@" "];
            [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
            [self setErrString:@""];
            [self setBreakError:NO];
        }
        else {
            [self setErrString:@"Invalid PC/Reg Breakpoint. Set PC/Reg in Registers area first."];
            [self setBreakError:YES];
        }
        
        mruOperand = true;
        mruOperator = false;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprMemAppend
// Append a chosen memory breakpoint from the list
// -----------------------------------------------------------------
- (IBAction)exprMemAppend:(id)sender {
    
    NSPopUpButton   *selectBox = (NSPopUpButton *)sender;
    NSString        *original;
    NSMutableString *newExpr;
    int             addrIndex;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        original  = [self selExprString];
        addrIndex = [selectBox indexOfSelectedItem] + ADDR_ID_OFFSET + 1;
        if(addrIndex > ADDR_ID_OFFSET && addrIndex <= addrCount + ADDR_ID_OFFSET) {
            infixExpr[infixCount++] = addrIndex - 1;
            newExpr = [NSMutableString stringWithString:original];
            [newExpr appendFormat:@" A%d",addrIndex - ADDR_ID_OFFSET];
            if(addrIndex < 10) [newExpr appendString:@" "];
            [newExpr appendString:@" "];
            [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
            [self setErrString:@""];
            [self setBreakError:NO];
        }
        else {
            [self setErrString:@"Invalid Memory Breakpoint. Set Memory in Memory area first."];
            [self setBreakError:YES];
        }
        
        mruOperand = true;
        mruOperator = false;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprAndAppend
// Append an AND token to the breakpoint expression
// -----------------------------------------------------------------
- (IBAction)exprAndAppend:(id)sender {
    
    NSString        *original;
    NSMutableString *newExpr;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        // Represent and AND_OP in the int array
        original = [self selExprString];
        newExpr = [NSMutableString stringWithString:original];
        infixExpr[infixCount++] = MAX_BPOINTS + AND_OP;
        [newExpr appendString:@" AND "];
        [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
        mruOperand = false;
        mruOperator = true;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprOrAppend
// Append an AND token to the breakpoint expression
// -----------------------------------------------------------------
- (IBAction)exprOrAppend:(id)sender {
    
    NSString        *original;
    NSMutableString *newExpr;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        // Represent and AND_OP in the int array
        original = [self selExprString];
        newExpr = [NSMutableString stringWithString:original];
        infixExpr[infixCount++] = MAX_BPOINTS + OR_OP;
        [newExpr appendString:@" OR  "];
        [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
        mruOperand = false;
        mruOperator = true;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprBackspace
// Removes the last token from the breakpoint expression
// -----------------------------------------------------------------
- (IBAction)exprBackspace:(id)sender {
 
    NSString *original, *newExpr;
    
    original = [self selExprString];
    if ([original length] == 0) return;
    newExpr  = [original substringToIndex:[original length]-5];
    [self setSelExprString:newExpr];


    // Are we deleting a left paren?
    if(infixExpr[infixCount - 1] == LPAREN)
        parenCount--;
    // Are we deleting a right paren?
    else if(infixExpr[infixCount - 1] == RPAREN)
        parenCount++;
    infixCount--;
    
    // Is the last element an operand (between 0 and MAX_BPOINTS)?
    if(infixCount > 0 &&
       infixExpr[infixCount-1] < MAX_BPOINTS && infixExpr[infixCount-1] >= 0)
        mruOperand = true;
    else {
        mruOperand = false;
        // Is the last element not a left paren or a right paren?
        if((infixExpr[infixCount - 1] != LPAREN) &&
           (infixExpr[infixCount - 1] != RPAREN))
            mruOperator = true;
        else
            mruOperator = false;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprLParenAppend
// Appends a left parenthesis to the expression
// -----------------------------------------------------------------
- (IBAction)exprLParenAppend:(id)sender {
    
    NSString        *original;
    NSMutableString *newExpr;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        original = [self selExprString];
        newExpr  = [NSMutableString stringWithString:original];
        infixExpr[infixCount++] = LPAREN;
        [newExpr appendString:@"  (  "];
        [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
        mruOperand = false;
        mruOperator = false;
        parenCount++;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// exprRParenAppend
// Appends a left parenthesis to the expression
// -----------------------------------------------------------------
- (IBAction)exprRParenAppend:(id)sender {
    
    NSString        *original;
    NSMutableString *newExpr;
    
    // Make sure there is room for more array elements
    if(infixCount < MAX_LB_NODES) {
        original = [self selExprString];
        newExpr  = [NSMutableString stringWithString:original];
        infixExpr[infixCount++] = RPAREN;
        [newExpr appendString:@"  )  "];
        [self setSelExprString:[NSString stringWithFormat:@"%@",newExpr]];
        mruOperand = false;
        mruOperator = false;
        parenCount--;
    }
    
    [self updateExprButtons];
}

// -----------------------------------------------------------------
// updateExprButtons
// Enforces the availability of expression builder buttons
// -----------------------------------------------------------------
- (void)updateExprButtons {
    
    int selection = [self selExprBP];
    
    [self setExprClear:YES];
    [self setExprClearAll:YES];
    
    // Are the editable fields exposed for data entry?
    if(selection > 0) {
        // Don't allow hanging operators or incomplete expressions
        if(parenCount == 0 && (mruOperand || (infixExpr[infixCount-1] == RPAREN)))
            [self setExprSet:YES];
        else
            [self setExprSet:NO];
        
        int mruElement = 0;
        bool startExpr = false;
        if(infixCount > 0)
            mruElement = infixExpr[infixCount - 1];
        else
            startExpr = true;
        
        // Force operands to be separated by operators.
        if(mruOperator || (mruElement == LPAREN) || startExpr) {
            [self setExprReg:YES];
            [self setExprMem:YES];
            [self setExprAnd:NO];
            [self setExprOr:NO];
        }
        else if(mruOperand || (mruElement == RPAREN)) {
            [self setExprReg:NO];
            [self setExprMem:NO];
            [self setExprAnd:YES];
            [self setExprOr:YES];
        }
        
        // Is there an legal element preceding the left paren,
        // or is this the first element in the expression?
        if(infixCount == 0 || mruOperator ||
           (infixExpr[infixCount - 1] == LPAREN))
            [self setExprLParen:YES];
        else
            [self setExprLParen:NO];
        
        // Are there already left parens and not an operator in the last element?
        if(parenCount > 0 && !mruOperator && (mruElement != LPAREN))
            [self setExprRParen:YES];
        else
            [self setExprRParen:NO];
        
        // Is there anything available to delete from the expression?
        if(infixCount > 0)
            [self setExprBack:YES];
        else
            [self setExprBack:NO];
        
        // Regardless of anything else, if max count has been reached,
        // disable all except the backspace key.
        if(infixCount >= MAX_LB_NODES) {
            [self setExprReg:NO];
            [self setExprMem:NO];
            [self setExprAnd:NO];
            [self setExprOr:NO];
            [self setExprBack:NO];
            [self setExprLParen:NO];
            [self setExprRParen:NO];
        }
    }
    
    else {
        [self setExprReg:NO];
        [self setExprMem:NO];
        [self setExprAnd:NO];
        [self setExprOr:NO];
        [self setExprBack:NO];
        [self setExprLParen:NO];
        [self setExprRParen:NO];
    }
}

// -----------------------------------------------------------------
// clearExprBP
// Clears the current breakpoint expression if set
// -----------------------------------------------------------------
- (IBAction)clearExprBP:(id)sender {
    
    int selection = [self selExprBP];
    if (selection < 1 || selection > exprCount) return;
    
    BPointExpr *temp = &bpExpressions[selection-1];
    for (int curRow = selection; curRow < exprCount; curRow++)
        bpExpressions[curRow-1] = bpExpressions[curRow];
    exprCount--;
    bpExpressions[exprCount] = *temp;
    bpExpressions[exprCount].isEnabled(false);
    
    [self updateExprBPList];
    if ((selection > exprCount) && (selection > 1)) selection = exprCount;
    [self setSelExprBP:selection];    
}

// -----------------------------------------------------------------
// clearAllExprBP
// Clears the current breakpoint expression if set
// -----------------------------------------------------------------
- (IBAction)clearAllExprBP:(id)sender {
    
    // Invalidate all breakpoint expressions
    exprCount = 0;
    
    [self updateExprBPList];
}

// -----------------------------------------------------------------
// updateExprBPList
// Updates the list of breakpoint expressions
// -----------------------------------------------------------------
- (void)updateExprBPList {
    
    NSMutableArray  *worker;
    NSString        *line, *textLine;
    NSString        *breakNum, *expression, *enabled, *count;
    NSString        *numSpacer;
    NSTextStorage   *textStore;
    BPointExpr      *curBPoint;
    NSRange         textRange;
    NSDictionary    *textAttr;
    
    // Reset the list of options and regenerate
    worker      = [self exprBreakpoints];
    [worker removeAllObjects];
    [exprBPList clearText];
    [exprBPList appendString:@"     On  Count   Expression\n"];              // Header column for text view
                            //(50) YES 123456  Expression 
    [worker addObject:@"Select Breakpoint Expression"];                     // Instructions....
    for (int i = 1; i <= exprCount; i++) {
        
        curBPoint = &bpExpressions[i-1];
        breakNum = [NSString stringWithFormat:@"%d",i];                     // Breakpoint Index
        if (i < 10) numSpacer = @" ";                                       // Spacer when single digit index
        else numSpacer = @"";
        if (curBPoint->isEnabled()) enabled = @"YES";                       // Breakpoint enabled
        else enabled = @"NO ";
        count = [NSString stringWithFormat:@"%-6d",curBPoint->getCount()];  // Breakpoint count
        expression = curBPoint->getExprString();
        
        line = [NSString stringWithFormat:@"%@%@ %@ %@%@",                  // Format becomes
                breakNum, numSpacer, enabled, count, expression];           // ## YES ######  Expression
        [worker addObject:line];
        textLine = [NSString stringWithFormat:@"(%@)%@ %@ %@%@",            // Format becomes
                    breakNum, numSpacer, enabled, count, expression];       // (##) YES ######  Expression
        [exprBPList appendString:textLine];
        [exprBPList appendString:@"\n"];        
        
    }
    
    // Placeholder for new breakpoint
    if (exprCount < MAX_BPOINTS) {
        line = [NSString stringWithFormat:@"%d New Breakpoint Expression...",exprCount+1];
        [worker addObject:line];
    }
    
    // Ensure font & color are correct for HUD window text
    textStore = [exprBPList textStorage];
    textRange = NSMakeRange(0, [textStore length]);
    textAttr  = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSColor whiteColor], NSForegroundColorAttributeName,
                 [NSFont fontWithName:@"Courier" size:10], NSFontAttributeName, nil];
    [textStore setAttributes:textAttr range:textRange];
    
    // Update the mutable array binding
    [self setExprBreakpoints:worker];    
}

@end

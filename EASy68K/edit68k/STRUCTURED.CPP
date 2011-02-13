/***********************************************************************

 		STRUCASM.CPP
  This file contains the routines to assemble structured code.

   Author: Chuck Kelly,
           Monroe County Community College
           http://www.monroeccc.edu/ckelly

 Modified: 2011-01-31
           Robert Bartlett-Schneider
           Modified to remove usage of AnsiString class
 
 ************************************************************************/

#include <stack.h>
#include <vector.h>
#include <stdio.h>
#include <ctype.h>
//#include <string.h>
//#include <string>
#include <vector>
#include <stack>
#include "asm.h"

// MSW - maximum size of replacement stack
// increase as necessary. Should be dynamically allocated
#define MAX_STACK_SIZE 4096


extern char line[256];		// Source line
extern bool listFlag;
extern bool pass2;		// Flag set during second pass
extern int loc;		// The assembler's location counter
extern unsigned int stcLabelI;  // structured if label number
extern unsigned int stcLabelW;  // structured while label number
extern unsigned int stcLabelR;  // structured repeat label number
extern unsigned int stcLabelF;  // structured for label number
extern unsigned int stcLabelD;  // structured dbloop label number
extern int errorCount, warningCount;
extern bool SEXflag;            // true expands structured listing
extern int lineNum;
extern FILE *listFile;		// Listing file
extern bool skipList;           // true to skip listing line in ASSEMBLE.CPP
extern int  macroNestLevel;     // used by macro processing
extern char lineIdent[];        // "s" used to identify structure in listing

// prototypes
const char *getBcc(char *cc, int mode, int orm);
void outCmpBcc(char *size, char *op1, char *cc, char *op2, char *op3,
               char *label, int &error);
void assembleStc(char* line);

const unsigned int stcMask  = 0xF0000000;
const unsigned int stcMaskI = 0x00000000;
const unsigned int stcMaskW = 0x10000000;
const unsigned int stcMaskF = 0x20000000;
const unsigned int stcMaskR = 0x30000000;
const unsigned int stcMaskD = 0x40000000;

// constants for use with BccCodes[] below to select proper column.
const int RN_EA_OR = 2;
const int EA_IM_OR = 2;
const int IF_CC = 1;            // IF <cc>
const int RN_EA = 1;
const int EA_IM = 1;
const int EA_RN = 3;
const int IM_EA = 3;
const int EA_RN_OR = 4;
const int IM_EA_OR = 4;

const int BCC_COUNT = 16;
const int LAST_TOKEN = 11;      // highest token possible of structure

// Global variables
char stcLabel[256];

// MSW - replacement c-based stack 
//int stcStack[MAX_STACK_SIZE];
//int *currStackPtr = stcStack;

// Make a stack using a vector container
stack<int,vector<int> > stcStack;
// Make a stack for saving dbloop register number
stack<char, vector<char> > dbStack;
// Make a stack for saving FOR arguments
stack<char*, vector<char*> > forStack;

// This table contains the branch condition codes to use for the different
// conditional expressions.
const char* BccCodes[BCC_COUNT][5] = {
//  <cc>     <-- original CC used in structured code
//            Rn<cc>ea   Rn<cc>ea OR   ea<cc>Rn    ea<cc>Rn OR  <-- if used like this
//           CMP ea,Rn    CMP ea,Rn   CMP ea,Rn    CMP ea,Rn    <-- use this CMP operation
//            ea<cc>#n   ea<cc>#n OR   #n<cc>ea    #n<cc>ea OR  <-- if used like this
//           CMP #n,ea    CMP #n,ea   CMP #n,ea    CMP #n,ea    <-- use this CMP operation
   "<GT>",      "BLE",      "BGT",      "BGE",      "BLT",    //<-- with condition below
   "<GE>",      "BLT",      "BGE",      "BGT",      "BLE",
   "<LT>",      "BGE",      "BLT",      "BLE",      "BGT",
   "<LE>",      "BGT",      "BLE",      "BLT",      "BGE",
   "<EQ>",      "BNE",      "BEQ",      "BNE",      "BEQ",
   "<NE>",      "BEQ",      "BNE",      "BEQ",      "BNE",
   "<HI>",      "BLS",      "BHI",      "BHS",      "BLO",
   "<HS>",      "BLO",      "BHS",      "BHI",      "BLS",
   "<CC>",      "BLO",      "BCC",      "BHI",      "BLS",
   "<LO>",      "BHS",      "BLO",      "BLS",      "BHI",
   "<CS>",      "BHS",      "BCS",      "BLS",      "BHI",
   "<LS>",      "BHI",      "BLS",      "BLO",      "BHS",
   "<MI>",      "BPL",      "BMI",      "BPL",      "BMI",
   "<PL>",      "BMI",      "BPL",      "BMI",      "BPL",
   "<VC>",      "BVS",      "BVC",      "BVS",      "BVC",
   "<VS>",      "BVC",      "BVS",      "BVC",      "BVS"


};

//-------------------------------------------------------
// returns a branch instruction
// or is 1 on ea <cc> ea OR, 0 otherwise
//-------------------------------------------------------
const char *getBcc(char *cc, int mode, int orm) {
    for (int i = 0; i < strlen(cc); i++)
    {
        cc[i] = toupper(cc[i]);
    }
    for (int i=0; i<BCC_COUNT; i++) {
        if (stricmp(cc, BccCodes[i][0]) == 0)
            return BccCodes[i][mode + orm];
    }
    return "B??";
}

//-------------------------------------------------------
// output a CMP and Branch to perform the specified expression
// Pre: the code is in all caps
// token[0] is the first token in the structure following the keyword. Normally
// the size. (IF.B  token[0] would be .B). The size may be missing in which case
// token[0] would contain the first operand or <cc> in the structure.
//    token number
//     0     1     2     3     4     5     6     7     8     9
//    <cc>  THEN
//    <cc>   OR   .B   <cc>  THEN
//    D1   <cc>   D2    OR    .B    <cc>  THEN
//    .B   <cc>  THEN
//    .B   <cc>   OR   <cc>  THEN
//    .B   <cc>   OR    .B   <cc>  THEN
//    .B    D0   <cc>   D1   THEN
//    .B   <cc>   AND   .B    D0   <cc>   D1   THEN
//    .B    D0   <cc>   D1    AND   .B    D2   <cc>   D3   THEN
// output a CMP and Branch to perform the specified expression
//-------------------------------------------------------
//void outCmpBcc( char *size, char *op1, char *cc, char *op2, char *op3, char *label, int &error) {
void outCmpBcc( char *token[], char *last, char *label, int &error) {
    
    char stcLine[256], stcCmp[256], extent[256];
    int orm=0;
    // int extI=0;
    int n=0;
    
    try {
        error = OK;
        if (token[n][0] == '.') {
            if (token[n][1] == 'B')
                strcpy(stcCmp, "\tCMP.B\t");
            else if (token[n][1] == 'W')
                strcpy(stcCmp, "\tCMP.W\t");
            else if (token[n][1] == 'L')
                strcpy(stcCmp, "\tCMP.L\t");
            else {
                error = SYNTAX;
                return;
            }
            n++;                        // token[n] at 1
        } else
            strcpy(stcCmp, "\tCMP.W\t");
        
        // Determine the size of extent if present
        if (last[0] == '.') {
            if (last[1] == 'S')
                strcpy(extent,".S\t");
            else if (last[1] == 'L')
                strcpy(extent,".L\t");
            else {
                error = SYNTAX;
                return;
            }
        } else
            strcpy(extent,"\t");
        
        if ( !(stricmp(token[n+1], "OR")) || !(stricmp(token[n+3], "OR"))) {
            orm = 1;
            strcpy(extent,".S\t");            // first branch with OR logic is always short
        }
        
        if (token[n][0] == '<') {                                                                         // IF <cc> THEN
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n],IF_CC,orm),extent,label);
            assembleStc(stcLine);
        }else if (token[n][0] == '#') {                                                                   // #nn <cc> ea
            sprintf(stcLine,"%s%s,%s,\n",stcCmp,token[n],token[n+2]);
            assembleStc(stcLine);
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n+2],IM_EA,orm),extent,label);
            assembleStc(stcLine);
        }else if (token[n+2][0] == '#') {                                                                 // ea <cc> #nn
            sprintf(stcLine, "%s%s,%s\n", stcCmp, token[n+2], token[n]);
            assembleStc(stcLine);
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n+1],EA_IM,orm),extent,label);
            assembleStc(stcLine);
        }else if ((token[n][0]=='A' || token[n][0]=='D' || token[n][0]=='a' || token[n][0]=='d') &&       // Rn <cc> ea
                  isRegNum(token[n][1])) {
            sprintf(stcLine,"%s%s,%s\n",stcCmp,token[n+2],token[n]);
            assembleStc(stcLine);
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n+1],RN_EA,orm),extent,label);
            assembleStc(stcLine);
        }else if ((token[n+2][0]=='A' || token[n+2][0]=='D' || token[n+2][0]=='a' || token[n][0]=='d') && // ea <cc> Rn
                  isRegNum(token[n+2][1])) {
            sprintf(stcLine,"%s%s,%s\n",stcCmp,token[n],token[n+2]);
            assembleStc(stcLine);
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n+1],EA_RN,orm),extent,label);
            assembleStc(stcLine);
        }else if ((token[n][0]=='(' && token[n][3]==')' && token[n][4]=='+')) {                           // (An)+ <cc> (An)+  also supports (SP)+ (MUST BE LAST IN IF-ELSE CHAIN)
            sprintf(stcLine,"%s%s,%s\n",stcCmp,token[n],token[n+2]);
            assembleStc(stcLine);
            sprintf(stcLine,"\t%s%s%s\n",getBcc(token[n+1],RN_EA,orm),extent,label);
            assembleStc(stcLine);
        }else{
            error = SYNTAX;
        }
    }catch(...){
        error = SYNTAX;
    }
}

//-------------------------------------------------------
// asmStructure()
/*
  Structured statements
    items in brackets [] are optional.

    An expression consists of either one of the following:
      <cc>
      op1 <cc> op2

    IF expression THEN[.S|.L]
    IF[.B|.W|.L] expression THEN[.S|.L]
    IF[.B|.W|.L] expression OR[.B|.W|.L]  expression THEN[.S|.L]
    IF[.B|.W|.L] expression AND[.B|.W|.L] expression THEN[.S|.L]

    ELSE[.S|.L]

    ENDI

    WHILE expression DO[.S|.L]
    WHILE[.B|.W|.L] expression DO[.S|.L]
    WHILE[.B|.W|.L] expression OR[.B|.W|.L]  expression DO[.S|.L]
    WHILE[.B|.W|.L] expression AND[.B|.W|.L] expression DO[.S|.L]

    ENDW

    REPEAT

    UNTIL expression [DO[.S|.L]]
    UNTIL[.B|.W|.L] expression [DO[.S|.L]]
    UNTIL[.B|.W|.L] expression OR[.B|.W|.L]  expression [DO[.S|.L]]
    UNTIL[.B|.W|.L] expression AND[.B|.W|.L] expression [DO[.S|.L]]

    FOR[.B|.W|.L] op1 = op2 TO     op3        DO[.S|.L]
    FOR[.B|.W|.L] op1 = op2 TO     op3 BY op3 DO[.S|.L]
    FOR[.B|.W|.L] op1 = op2 DOWNTO op3        DO[.S|.L]
    FOR[.B|.W|.L] op1 = op2 DOWNTO op3 BY op3 DO[.S|.L]

    ENDF

    DBLOOP op1 = op2
    UNLESS
    UNLESS <F>
    UNLESS[.B|.W|.L] expression

    token number
     1     2     3     4     5     6     7     8     9    10    11    12
    IF   <cc>  THEN
    IF   <cc>   OR    .B   <cc>  THEN
    IF    .B   <cc>   THEN
    IF    .B   <cc>   OR   <cc>  THEN
    IF    .B   <cc>   OR    .B   <cc>  THEN
    IF    .B    D0    <cc>  D1   THEN
    IF    .B   <cc>   AND   .B    D0   <cc>   D1    THEN
    IF    D0   <cc>   D1    OR   <cc>  THEN
    IF    .B    D0    <cc>  D1    OR   <cc>  THEN
    IF    .B    D0    <cc>  D1    AND   .B    D2    <cc>  D3   THEN   .S
*/
//-------------------------------------------------------
int asmStructure(int size, char *label, char *arg, int *errorPtr)
{
    try {
        
        char *token[256];             // pointers to tokens
        char tokens[512];             // place tokens here
        char capLine[256];
        char tokenEnd[10];            // last token of structure goes here
        char stcLabel[256], stcLabel2[256], stcLine[256], sizeStr[256], extent[256];
        // symbolDef *symbol;
        int error;
        // int value;
        // bool backRef;
        int n = 2;                    // token index
        int i;
        
        if (*label)                                         // if label
            define(label, loc, pass2, true, errorPtr);      // define label
        
        strcap(capLine, line);                              // capitalize line
        error = OK;
        if (pass2 && listFlag) {
            if (!(macroNestLevel > 0 && skipList == true))  // if not called from macro with listing off
            {
                listLoc();
                if (macroNestLevel > 0)                     // if called from macro
                    listLine(line, lineIdent);              // tag line as macro
                else
                    listLine(line);
            }
        }
        
        tokenize(capLine, ". \t\n", token, tokens);         // tokenize statement
        
        if (token[n][0] == '.')
            n = 3;
        
        // -------------------- IF --------------------
        // IF[.B|.W|.L] op1 <cc> op2 [OR/AND[.B|.W|.L]  op3 <cc> op4] THEN
        if (!(stricmp(token[1], "IF"))) {               // IF ?
            sprintf(stcLabel, "_%08x", stcLabelI);
            tokenEnd[0] = '\0';
            for (i=3; i<=LAST_TOKEN; i++) {
                if (!(stricmp(token[i], "THEN"))) { // find THEN
                    strncpy(tokenEnd, token[i+1],3);    // copy branch distance to tokenEnd
                    break;
                }
            }
            if(i > LAST_TOKEN) {                        // if THEN not found
                error = THEN_EXPECTED;
                NEWERROR(*errorPtr, error);
            }
            //           .B/W/L       op1       <cc>       op2   THEN/OR/AND  THEN.?   label
            outCmpBcc(&token[2], tokenEnd, stcLabel, error);
            NEWERROR(*errorPtr, error);
            if (!(stricmp(token[n+1], "OR"))) {    // IF <cc> OR
                strcpy(stcLabel2, stcLabel);
                stcLabelI++;
                sprintf(stcLabel, "_%08x", stcLabelI);
                //           .B/W/L       op3      <cc>      op4       THEN      THEN.?    label
                outCmpBcc(&token[n+2], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
                sprintf(stcLine, "%s\n", stcLabel2);
                assembleStc(stcLine);
            } else if (!(stricmp(token[n+3], "OR"))) { // IF ea <cc> ea OR
                strcpy(stcLabel2, stcLabel);
                stcLabelI++;
                sprintf(stcLabel,"_%08x", stcLabelI);
                //           .B/W/L       op3      <cc>      op4       THEN      THEN.?    label
                outCmpBcc(&token[n+4], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
                sprintf(stcLine, "%s\n", stcLabel2);
                assembleStc(stcLine);
            } else if (!(stricmp(token[n+1], "AND"))) { // IF <cc> AND
                //            .B/W/L       op3       <cc>      op4       THEN     THEN.?    label
                outCmpBcc(&token[n+2], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
            } else if (!(stricmp(token[n+3], "AND"))) { // IF ea <cc> ea AND
                //            .B/W/L       op3       <cc>      op4       THEN     THEN.?    label
                outCmpBcc(&token[n+4], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
            }
            
            stcStack.push(stcLabelI);
            stcLabelI++;                            // prepare label for next if
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- ELSE --------------------
        if (!(stricmp(token[1], "ELSE"))) {
            unsigned int elseLbl = stcStack.top();
            stcStack.pop();
            if ((elseLbl & stcMask) != stcMaskI)
                NEWERROR(*errorPtr, NO_IF);
            // determine size of extent
            if (token[2][0] == '.') {
                if (token[2][1] == 'S')
                    strcpy(extent, ".S\t");
                else if (token[2][1] == 'L')
                    strcpy(extent, ".L\t");
                else {
                    NEWERROR(*errorPtr, SYNTAX);
                }
            } else {
                strcpy(extent, "\t");
            }
            
            sprintf(stcLabel, ".%08x", stcLabelI);
            sprintf(stcLine, "\tBRA%s%s\n", extent, stcLabel);
            assembleStc(stcLine);
            stcStack.push(stcLabelI);
            stcLabelI++;
            sprintf(stcLine, ".%08x\n", elseLbl);
            assembleStc(stcLine);
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- ENDI --------------------
        if (!(stricmp(token[1], "ENDI"))) {
            unsigned int endiLbl = stcStack.top();
            stcStack.pop();
            if ((endiLbl & stcMask) != stcMaskI)    // if label is not from an IF
                NEWERROR(*errorPtr, NO_IF);
            sprintf(stcLine, ".%08x\n", endiLbl);
            assembleStc(stcLine);
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- WHILE --------------------
        // WHILE[.B|.W|.L] op1 <cc> op2 [OR/AND[.B|.W|.L]  op3 <cc> op4] DO
        // WHILE <T> D0 create infinite loop
        if (!(stricmp(token[1], "WHILE"))) {        // WHILE
            sprintf(stcLine, "_%08x\n", stcLabelW);
            assembleStc(stcLine);
            stcStack.push(stcLabelW);
            stcLabelW++;
            sprintf(stcLabel,"_%08x",stcLabelW);
            tokenEnd[0] = '\0';
            for (i=3; i<=LAST_TOKEN; i++) {
                if (!(stricmp(token[i], "DO"))) {   // if DO
                    strncpy(tokenEnd, token[i+1], 3);   // copy branch distance to tokenEnd
                    break;
                }
            }
            if(i > LAST_TOKEN)                          // if DO not found
                NEWERROR(*errorPtr, DO_EXPECTED);
            if ((stricmp(token[n], "<T>"))) {       // if not infinite loop <T>
                //            .B/W/L      op1       <cc>       op2   DO/OR/AND    DO.?     label
                outCmpBcc(&token[2], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
                if (!(stricmp(token[n+1], "OR"))) {      // WHILE <cc> OR
                    strcpy(stcLabel2, stcLabel);
                    stcLabelW++;
                    sprintf(stcLabel,"_%08x",stcLabelW);
                    //           .B/W/L        op3      <cc>      op4       DO       DO.?      label
                    outCmpBcc(&token[n+2], tokenEnd, stcLabel, error);
                    NEWERROR(*errorPtr, error);
                    sprintf(stcLabel,"%s\n",stcLabel2);
                    assembleStc(stcLine);
                } else if (!(stricmp(token[n+3], "OR"))) { // WHILE ea <cc> ea OR
                    strcpy(stcLabel2, stcLabel);
                    stcLabelW++;
                    sprintf(stcLabel,"_%08x",stcLabelW);
                    //           .B/W/L        op3      <cc>      op4       DO       DO.?      label
                    outCmpBcc(&token[n+4], tokenEnd, stcLabel, error);
                    NEWERROR(*errorPtr, error);
                    sprintf(stcLine,"%s\n",stcLabel2);
                    assembleStc(stcLine);
                } else if (!(stricmp(token[n+1], "AND"))) { // WHILE <cc> AND
                    //           .B/W/L       op3       <cc>      op4       DO       DO.?      label
                    outCmpBcc(&token[n+2], tokenEnd, stcLabel, error);
                    NEWERROR(*errorPtr, error);
                } else if (!(stricmp(token[n+3], "AND"))) { // WHILE ea <cc> ea AND
                    //           .B/W/L       op3       <cc>      op4       DO       DO.?      label
                    outCmpBcc(&token[n+4], tokenEnd, stcLabel, error);
                    NEWERROR(*errorPtr, error);
                }
            }
            
            stcStack.push(stcLabelW);
            stcLabelW++;
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- ENDW --------------------
        if (!(stricmp(token[1], "ENDW"))) {
            unsigned int endwLbl = stcStack.top();
            stcStack.pop();
            if ((endwLbl & stcMask) != stcMaskW)        // if label is not from a WHILE
                NEWERROR(*errorPtr, NO_WHILE);
            unsigned int whileLbl = stcStack.top();
            stcStack.pop();
            sprintf(stcLine,"\tBRA\t.%08x\n",whileLbl);
            assembleStc(stcLine);
            sprintf(stcLine,"_%08x\n",endwLbl);
            assembleStc(stcLine);
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- REPEAT --------------------
        if (!(stricmp(token[1], "REPEAT"))) {
            sprintf(stcLabel,"_%08x",stcLabelR);
            sprintf(stcLine,"_%s\n",stcLabel);
            assembleStc(stcLine);
            stcStack.push(stcLabelR);
            stcLabelR++;
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- UNTIL --------------------
        // UNTIL[.B|.W|.L] op1 <cc> op2 [OR/AND[.B|.W|.L]  op3 <cc> op4] DO
        if (!(stricmp(token[1], "UNTIL"))) {                     // UNTIL
            unsigned int untilLbl = stcStack.top();
            stcStack.pop();
            if ((untilLbl & stcMask) != stcMaskR)               // if label is not from a REPEAT
                NEWERROR(*errorPtr, NO_REPEAT);
            sprintf(stcLabel2,"_%08x",untilLbl);
            sprintf(stcLabel,"_%08x",stcLabelR);
            
            tokenEnd[0] = '\0';
            for (i=3; i<=LAST_TOKEN; i++) {
                if (!(stricmp(token[i], "DO"))) {                // if DO
                    strncpy(tokenEnd, token[i+1], 3);           // copy branch distance to tokenEnd
                    break;
                }
            }
            if(i > LAST_TOKEN)                                  // if DO not found
                NEWERROR(*errorPtr, DO_EXPECTED);
            if (!(stricmp(token[n+1], "OR"))) {                 // UNTIL <cc> OR
                //           .B/W/L       op1       <cc>       op2   DO/OR/AND    DO.?     label
                outCmpBcc(&token[2], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
                //           .B/W/L       op3      <cc>      op4       DO         DO.?     label
                outCmpBcc(&token[n+2], tokenEnd, stcLabel2, error);
                sprintf(stcLine,"%s\n",stcLabel);               // output label for first OR branch
                assembleStc(stcLine);
                stcLabelR++;
                NEWERROR(*errorPtr, error);
                
            } else if (!(stricmp(token[n+3], "OR"))) {          // UNTIL ea <cc> ea OR
                //           .B/W/L       op1       <cc>       op2   DO/OR/AND    DO.?     label
                outCmpBcc(&token[2], tokenEnd, stcLabel, error);
                NEWERROR(*errorPtr, error);
                //           .B/W/L       op3      <cc>      op4       DO         DO.?     label
                outCmpBcc(&token[n+4], tokenEnd, stcLabel2, error);
                sprintf(stcLine,"%s\n",stcLabel);               // output label for first OR branch
                assembleStc(stcLine);
                stcLabelR++;
                NEWERROR(*errorPtr, error);
                
            } else {
                //           .B/W/L       op1       <cc>       op2   DO/OR/AND    DO.?     label
                outCmpBcc(&token[2], tokenEnd, stcLabel2, error);
                NEWERROR(*errorPtr, error);
                if (!(stricmp(token[n+1], "AND"))) {             // UNTIL <cc> AND
                    //           .B/W/L       op3      <cc>      op4       DO         DO.?     label
                    outCmpBcc(&token[n+2], tokenEnd, stcLabel2, error);
                    NEWERROR(*errorPtr, error);
                } else if (!(stricmp(token[n+3], "AND"))) {      // UNTIL ea <cc> ea AND
                    //           .B/W/L       op3      <cc>      op4       DO         DO.?     label
                    outCmpBcc(&token[n+4], tokenEnd, stcLabel2, error);
                    NEWERROR(*errorPtr, error);
                }
            }
            
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- FOR --------------------
        // FOR[.<size>] op1 = op2 TO op3 [BY op4] DO
        if (!(stricmp(token[1], "FOR"))) {
            
            // determine size of extent if present
            tokenEnd[0] = '\0';
            for (i=3; i<=LAST_TOKEN; i++) {
                if (!(stricmp(token[i], "DO"))) {        // find DO
                    strncpy(tokenEnd, token[i+1],3);    // copy branch distance to tokenEnd
                    break;
                }
            }
            if(i > LAST_TOKEN)                          // if DO not found
                NEWERROR(*errorPtr, DO_EXPECTED);
            if (tokenEnd[0] == '.') {
                if (tokenEnd[1] == 'S')
                    strcpy(extent,".S\t");
                else if (tokenEnd[1] == 'L')
                    strcpy(extent,".L\t");
                else {
                    NEWERROR(*errorPtr, SYNTAX);
                }
            } else {
                strcpy(extent,"\t");
            }
            
            // determine size of CMP
            if (token[2][0] == '.') {
                if (token[2][1] == 'B')
                    strcpy(sizeStr,".B\t");
                else if (token[2][1] == 'W')
                    strcpy(sizeStr,".W\t");
                else if (token[2][1] == 'L')
                    strcpy(sizeStr,".L\t");
                else {
                    NEWERROR(*errorPtr, SYNTAX);
                }
            } else
                strcpy(sizeStr,".W\t");
            
            sprintf(stcLine,"\tMOVE%s%s,%s\n",sizeStr,token[n+2],token[n]);
            if ((stricmp(token[n+2],token[n])))                                 // if op1 != op2 (FOR D1 = D1 TO ... skips move)
                assembleStc(stcLine);                                           // MOVE op2,op1
            
            sprintf(stcLabel,"_%08x",stcLabelF);
            stcLabelF++;
            sprintf(stcLabel2,"_%08x",stcLabelF);
            sprintf(stcLine,"\tBRA\t%s\n",stcLabel2);
            assembleStc(stcLine);                                               // BRA _20000001
            stcStack.push(stcLabelF);                                           // push _20000001
            
            sprintf(stcLine,"%s\n",stcLabel);
            assembleStc(stcLine);                                               // _20000000
            
            if (!(stricmp(token[n+3], "DOWNTO")))
                sprintf(stcLine,"\tBGE%s%s\n",extent,stcLabel);
            else
                sprintf(stcLine,"\tBLE%s%s\n",extent,stcLabel);
            forStack.push(stcLine);                                             // push Bcc _20000000
            
            sprintf(stcLine,"\tCMP%s%s,%s\n",sizeStr,token[n+4],token[n]);
            forStack.push(stcLine);                                             // push CMP instruction
            
            if (!(stricmp(token[n+5], "BY")))
                if (!(stricmp(token[n+3], "DOWNTO")))
                    sprintf(stcLine,"\tSUB%s%s,%s\n",sizeStr,token[n+6],token[n]);
                else
                    sprintf(stcLine,"\tADD%s%s,%s\n",sizeStr,token[n+6],token[n]);
                else
                    if (!(stricmp(token[n+3], "DOWNTO")))
                        sprintf(stcLine,"\tSUB%s#1,%s\n",sizeStr,token[n]);
                    else
                        sprintf(stcLine,"\tADD%s#1,%s\n",sizeStr,token[n]);
            forStack.push(stcLine);             // push SUB/ADD instruction
            
            stcLabelF++;                        // ready for next For instruction
            skipList = true;                    // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- ENDF --------------------
        if (!(stricmp(token[1], "ENDF"))) {
            unsigned int endfLbl = stcStack.top();
            stcStack.pop();
            if ((endfLbl & stcMask) != stcMaskF)                // if label is not from a FOR
                NEWERROR(*errorPtr, NO_FOR);
            else {
                strcpy(stcLine,forStack.top());
                assembleStc(stcLine);                           //   ADD|SUB op4,op1  or  ADD|SUB #1,op1
                forStack.pop();
                
                sprintf(stcLine,"_%08x\n",endfLbl);
                assembleStc(stcLine);                           // _20000001
                
                strcpy(stcLine,forStack.top());
                assembleStc(stcLine);                           //   CMP op3,op1
                forStack.pop();
                
                strcpy(stcLine,forStack.top());
                assembleStc(stcLine);                           //   BLT .2  or  BGT .2
                forStack.pop();
            }
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- DBLOOP --------------------
        // DBLOOP op1 = op2
        if (!(stricmp(token[1], "DBLOOP"))) {
            if (token[2][0] != 'D')
                NEWERROR(*errorPtr, SYNTAX);                                            // syntax must be DBLOOP Dn =
            if (token[2][1] < '0' || token[2][1] > '9' || token[3][0] != '=')
                NEWERROR(*errorPtr, SYNTAX);                                            // syntax must be DBLOOP Dn =
            dbStack.push(token[2][1]);                                                  // push Dn number
            sprintf(stcLine,"\tMOVE\t%s,%s\n",token[4],token[2]);
            if ((stricmp(token[2],token[4])))                                           // if op1 != op2 (DBLOOP D0 = D0 ... skips move)
                assembleStc(stcLine);                                                   //   MOVE op2,op1
            sprintf(stcLabel,"_%08x",stcLabelD);
            sprintf(stcLine,"%s\n",stcLabel);
            assembleStc(stcLine);
            stcStack.push(stcLabelD);
            stcLabelD++;
            skipList = true;                                                            // don't display this line in ASSEMBLE.CPP
        }
        
        // -------------------- UNLESS --------------------
        // UNLESS[.B|.W|.L] op1 <cc> op2]
        if (!(stricmp(token[1], "UNLESS"))) {                   // UNLESS
            unsigned int unlessLbl = stcStack.top();
            stcStack.pop();
            if ((unlessLbl & stcMask) != stcMaskD)              // if label is not from a DBLOOP
                NEWERROR(*errorPtr, NO_DBLOOP);
            sprintf(stcLabel,"\tD%c,_%08x",dbStack.top(),unlessLbl);
            dbStack.pop();
            
            // UNLESS <F> and UNLESS use DBRA
            if ( !(stricmp(token[n], "<F>")) || token[2][0] == '\0') {
                sprintf(stcLine,"\tDBRA%s\n",stcLabel);
                assembleStc(stcLine);
            } else {
                // determine size of CMP
                if (token[2][0] == '.') {
                    if (token[2][1] == 'B')
                        strcpy(sizeStr,".B\t");
                    else if (token[2][1] == 'W')
                        strcpy(sizeStr,".W\t");
                    else if (token[2][1] == 'L')
                        strcpy(sizeStr,".L\t");
                    else
                        NEWERROR(*errorPtr, SYNTAX);
                } else
                    strcpy(sizeStr,".W\t");
                
                if (token[n][0] == '<') {                                                                           // UNLESS <cc>
                    sprintf(stcLine,"\tD%s%s\n",getBcc(token[n],IF_CC,0),stcLabel);
                    assembleStc(stcLine);
                }else if (token[n][0] == '#') {                                                                     // UNLESS #nn <cc> ea
                    sprintf(stcLine,"\tCMP%s%s,%s\n",sizeStr,token[n],token[n+2]);
                    assembleStc(stcLine);
                    sprintf(stcLine,"\tD%s%s\n",getBcc(token[n+1],IM_EA,0),stcLabel);
                    assembleStc(stcLine);
                }else if (token[n+2][0] == '#') {                                                                   // UNLESS ea <cc> #nn
                    sprintf(stcLine,"\tCMP%s%s,%s\n",sizeStr,token[n+2],token[n]);
                    assembleStc(stcLine);
                    sprintf(stcLine,"\tD%s%s\n",getBcc(token[n+1],EA_IM,0),stcLabel);
                    assembleStc(stcLine);
                }else if ((token[n][0]=='A' || token[n][0]=='D' || token[n][0]=='a' || token[n][0]=='d') && 
                          isRegNum(token[n][1])) {                                                                  // UNLESS Rn <cc> ea
                    sprintf(stcLine,"\tCMP%s%s,%s\n",sizeStr,token[n+2],token[n]);
                    assembleStc(stcLine);
                    sprintf(stcLine,"\tD%s%s\n",getBcc(token[n+1],RN_EA,0),stcLabel);
                    assembleStc(stcLine);
                }else if ((token[n+2][0]=='A' || token[n+2][0]=='D' || token[n+2][0]=='a' || token[n+2][0]=='d') && // UNLESS ea <cc> Rn
                          isRegNum(token[n+2][1])) {
                    sprintf(stcLine,"\tCMP%s%s,%s\n",sizeStr,token[n],token[n+2]);
                    assembleStc(stcLine);
                    sprintf(stcLine,"\tD%s%s\n",getBcc(token[n+1],EA_RN,0),stcLabel);
                    assembleStc(stcLine);
                }else{
                    NEWERROR(*errorPtr, SYNTAX);
                }
            }
            skipList = true;                        // don't display this line in ASSEMBLE.CPP
        }
    }catch(...){
        NEWERROR(*errorPtr, SYNTAX);
    }
    return NORMAL;
}

void assembleStc(char* line)
{
    int error = OK;
    int i=0;
    while(lineIdent[i] && i<MACRO_NEST_LIMIT)
        i++;
    lineIdent[i]='s';     // line identifier for listing
    lineIdent[i+1]='\0';
    if (!SEXflag)
        skipList = true;
    else
        if (!(macroNestLevel > 0 && skipList == true)) // if not called from macro with listing off
            skipList = false;
    assemble(line, &error);
    lineIdent[i]='\0';
}

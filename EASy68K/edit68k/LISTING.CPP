/***********************************************************************
 *
 *		LISTING.C
 *		Listing File Routines for 68000 Assembler
 *
 *    Function: initList()
 *		Opens the specified listing file for writing. If the
 *		file cannot be opened, then the routine prints a
 *		message and exits.
 *
 *		listLine(char text[])
 *		Writes the specified line to the listing file. If
 *		the line is not a continuation, then the routine 
 *		includes the source line as the last part of the
 *		listing line. If an error occurs during the writing, 
 *		the routine prints a message and exits.
 *
 *		listLoc()
 *		Starts the process of assembling a listing line by 
 *		printing the location counter value into listData and
 *		initializing listPtr.
 *
 *		listObj()
 *		Prints the data whose size and value are specified in
 *		the object field of the current listing line. Bytes are
 *		printed as two digits, words as four digits, and
 *		longwords as eight digits, and a space follows each
 *		group of digits. 
 *		     If the item to be printed will not fit in the
 *		object code field, one of two things will occur. If
 *		CEXflag is TRUE, then the current listing line will be
 *		output to the listing file and the data will be printed
 *		on a continuation line. Otherwise, elipses ("...") will
 *		be printed to indicate the omission of values from the
 *		listing, and the data will not be added to the file. 
 *
 *	 Usage: initList(name)
 *		char *name;
 *
 *		listLine(line)
 *
 *		listLoc()
 *
 *		listObj(data, size)
 *		int data, size;
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 *    Modified: Chuck Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 *    Modified: 2011-01-26
 *              Robert Bartlett-Schneider
 *              Modified for Mac OS X Port
 *
 ************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include "asm.h"

/* Declarations of global variables */
extern int	loc;
extern bool pass2, CEXflag, continuation;
extern bool CREflag, offsetMode, showEqual;
extern char line[256];
extern FILE *listFile;
extern int lineNum;
extern int lineNumL68;

static char listData[49];   /* Buffer in which listing lines are assembled */

extern char *listPtr;       /* Pointer to above buffer (this pointer is
                             global because it is actually manipulated
                             by equ() and set() to put specially formatted
                             information in the listing) */

extern int errorCount, warningCount;    /* Number of errors and warnings */
extern char buffer[256];                //ck used to form messages for display in windows
extern char numBuf[20];
extern unsigned int startAddress;       // starting address of program

extern tabTypes tabType;
extern bool listFlag;
bool createdL68;                        // true when L68 (listing) file is created

//------------------------------------------------------------
// initList()
//------------------------------------------------------------
int initList(char *name)
{
    try {
        createdL68 = false;
        listFile = fopen(name, "w");
        if (!listFile) {
            sprintf(buffer,"Unable to create listing file");
            // TODO: (GUI) Send error to GUI
            //Application->MessageBox(buffer, "Error", MB_OK);
            return MILD_ERROR;
        }
        
        // Current time as a string for use in timestamp for listfile.
        time_t now = time(NULL);
        char *timeStr = ctime(&now);
        
        // Reserve room for starting address
        fprintf(listFile, "00000000 Starting Address\n");
        
        // Assembler Info and Timestamp
        fprintf(listFile, "Assembler used: %s\n", TITLE);
        fprintf(listFile, "Created On: %s\n\n", timeStr);
        
        createdL68 = true;
        return NORMAL;
    }
    catch( ... ) {
        sprintf(buffer, "ERROR: An exception occurred in routine 'initList'. \n");
        // TODO: (GUI) Send error to GUI
        printError(NULL, EXCEPTION, 0);
        return MILD_ERROR;
    }
}

//------------------------------------------------------------
// listLine()
//------------------------------------------------------------
int listLine(char text[], char lineIdent[])   // ck 4-2006 lineIdent[]
{
    // TODO: (WORKAROUND) This is a temporary local variable for fixed tab size
    int fixedTabSize = 4;
    bool fixedTabs = true;
    
    // FixedTabSize->Value
    try {
        if (!createdL68)
            return NORMAL;
        //TTextStuff *Active = (TTextStuff*)Main->ActiveMDIChild; //grab active mdi child
        fprintf(listFile, "%-32.32s", listData);
        if (!continuation) {
            // replace tab with spaces
            int i=0, j=0, k, t;
            while (text[i] && j < 255-8) {
                if (text[i] == '\t') {          // if tab
                    if (!fixedTabs) {
                        if (j <= TAB1)
                            t = TAB1 - j;
                        else if (j <= TAB2)
                            t = TAB2 - j;
                        else
                            t = TAB3 - j;
                    } else {                      // else fixed tabs
                        // TODO: (TABS) Create global variable or binding to determine tab size, replace with tabsize
                        t = fixedTabSize - (j % fixedTabSize);
                        
                    }
                    for (k=0; k<t; k++)       // replace with spaces
                        buffer[j++] = ' ';
                } else
                    buffer[j++] = text[i];        // else, copy character
                i++;
            }
            if (j>0 && buffer[j-1] != '\n')   // if line does not end in '\n'
                buffer[j++] = '\n';             // add it
            buffer[j] = '\0';
            
            if (lineIdent[0])                 // if line identifier
                fprintf(listFile, "%6d%s %s", lineNumL68, lineIdent, buffer);
            else
                fprintf(listFile, "%6d  %s", lineNumL68, buffer);
        } else
            putc('\n', listFile);
        
        if (ferror(listFile)) {
            sprintf(buffer,"Error writing to listing file\n");
            // TODO: (GUI) Send error to document window
            //Application->MessageBox(buffer, "Error", MB_OK);
            return MILD_ERROR;
        }
        
        lineNumL68++;
    }
    catch( ... ) {
        sprintf(buffer, "ERROR: An exception occurred in routine 'listLine'. \n");
        printError(NULL, EXCEPTION, 0);
        return MILD_ERROR;
    }
    
    return NORMAL;
}

//------------------------------------------------------------
// listLoc()
// TODO: (WORKAROUND) Examine compiler warning to see if casting is a bad idea. Cast as (unsigned long) to ignore...
// warning: format '%08lX' expects type 'long unsigned int', but argument 3 has type 'int'
//------------------------------------------------------------
int listLoc()
{
    if (offsetMode || showEqual)
        sprintf(listData, "%08lX= ", (unsigned long)loc);
    else
        sprintf(listData, "%08lX  ", (unsigned long)loc);
    listPtr = listData + 10;
    
    return NORMAL;
}

//------------------------------------------------------------
// listCond()
// Lists the value of skipCond
// when skipCond is True the conditional test was False
//------------------------------------------------------------
int listCond(bool cond)
{
    if (cond)
        sprintf(listPtr,"               %s ","FALSE");
    else
        sprintf(listPtr,"               %s ","TRUE");
    
    return NORMAL;
}

//------------------------------------------------------------
// listError()
// List error message
// Errors are always written to file if possible
// They are not turned off by NOLIST directive
// TODO: (POSSIBLE BUG) lineNum parameter shares the name as a global variable...... could cause issues
//------------------------------------------------------------
int listError(char *lineNum, char *errMsg)
{
    if (!createdL68)
        return NORMAL;
    fprintf(listFile, "%s", lineNum);         // write line number to file
    fprintf(listFile, "%s", errMsg);          // write error message to file
    return NORMAL;
}

//------------------------------------------------------------
// listObj
//------------------------------------------------------------
int listObj(int data, int size)
{
    if (!CEXflag && (listPtr - listData + size > 31)) {
        strcpy(listData + ((size == WORD_SIZE) ? 26 : 28), "...");
        return NORMAL;
    }
    if (CEXflag && (listPtr - listData + size > 31)) {
        listLine(line);
        strcpy(listData, "          ");
        listPtr = listData + 10;
        continuation = true;
    }
    switch (size) {
        case BYTE_SIZE_M: sprintf(listPtr, "%02X ", data & 0xFF);
            listPtr += 3;
            break;
        case WORD_SIZE: sprintf(listPtr, "%04X ", data & 0xFFFF);
            listPtr += 5;
            break;
            // TODO: (WORKAROUND) Make sure casting data as (unsigned long) isn't a bad workaround
        case LONG_SIZE: sprintf(listPtr, "%08lX ", (unsigned long)data);
            listPtr += 9;
            break;
        default: sprintf(buffer,"LISTOBJ: INVALID SIZE CODE!\n");
            // TODO: (GUI) Send error message to document window
            //Application->MessageBox(buffer, "Error", MB_OK);
            return MILD_ERROR;
    }
    
    return NORMAL;
}

//------------------------------------------------------------
// finishList()
//------------------------------------------------------------
int finishList()
{
  try {
    if (!createdL68)
      return NORMAL;
    putc('\n', listFile);
    if (errorCount > 0)
      fprintf(listFile, "%d error%s detected\n", errorCount,
                          (errorCount > 1) ? "s" : "");
    else {
      //***** DO NOT CHANGE THIS TEXT *****
      // "No error" is used by simulator to find the end of the code in the listing
      fprintf(listFile, "No errors detected\n");
    }
    if (warningCount > 0)
      fprintf(listFile, "%d warning%s generated\n", warningCount,
                          (warningCount > 1) ? "s" : "");
    else
      fprintf(listFile, "No warnings generated\n");

    // If OPT CRE Display Symbol Table ?
    if (CREflag)
      optCRE();   // Write symbol table to listing file

    // write starting address to first line of file
    rewind(listFile);                     // rewind to start of file
    fprintf(listFile, "%08lX", (unsigned long)startAddress);

    fclose(listFile);
    return NORMAL;
  }
  catch( ... ) {
    fclose(listFile);
    sprintf(buffer, "ERROR: An exception occurred in routine 'finishList'. \n");
    printError(NULL, EXCEPTION, 0);
    return MILD_ERROR;
  }
}
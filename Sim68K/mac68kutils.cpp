/***************************** 68000 SIMULATOR ****************************
 
 File Name: mac68kutils.cpp
 Version: 1.0 (Mac OS X)
 
 This file contains various routines used in the Mac OS X port of EASy68K
 
 The routines are :
 
 memDistance
 
 Created:  2011-03-17
           Robert Bartlett-Schneider
 
 ***************************************************************************/

#include "extern.h"

/**************************** long memDistance() ****************************

 name        : long memDistance(void *max, void *min, long size)
 parameters  : void *max : The upper bound of the memory range
               void *min : The lower bound of the memory range
 function    : calculates the distance between pointers, with a size specified
               by size, either BYTE_MASK, WORD_MASK, or LONG_MASK.
 
 ****************************************************************************/
long memDistance(void* max, void* min, long size)
{
    long factor = 0;
    switch (size)        // Determine distance factor (typically bytes)
    {
        case BYTE_MASK:
            factor = 1;
            break;
        case WORD_MASK:
            factor = 2;
            break;
        case LONG_MASK:
            factor = 4;
            break;
        default:
            factor = 1;
            break;
    }
    unsigned long *maxAddr = (unsigned long *)max; // Cast to unsigned long pointers (addresses)
    unsigned long *minAddr = (unsigned long *)min;
    unsigned long distance = (unsigned long)maxAddr - (unsigned long)minAddr;   // Calculate distance

    return (distance / factor);
}

/********************* NSString* binaryStringForValue() **********************
 
 name        : NSString* binaryStringForValue(unsigned short value)
 parameters  : unsigned short value : the number to be converted to a 16 bit
               binary string representation
 function    : Returns a string representation of a number as a 16 bit binary
               number. 
 
 ****************************************************************************/
NSString* binaryStringForValue(unsigned short value) 
{
    int position = WORD68K;                             // Start at end of string
    char buf[WORD68K+1];                
    buf[position--] = '\0';
    do {
        if (value & 1) buf[position--] = '1';           // Test and set bits
        else buf[position--] = '0';
        value >>= 1;                                    // Shift then loop
    } while (value > 0);
    
    while (position >= 0)                               // Fill remaining buffer space with 0
        buf[position--] = '0';
    
    return [NSString stringWithFormat:@"%s",buf];
}

/********************* NSNumber* binaryStringToValue() **********************
 
 name        : NSNumber* binaryStringToValue(NSString* input)
 parameters  : NSString* input : a string containing a binary representation
               of a 16 bit number.
 function    : Returns a string representation of a number as a 16 bit binary
 number. 
 
 ****************************************************************************/
NSNumber* binaryStringToValue(NSString *input)
{
    char buf[17];
    sprintf(buf, "%s", [input cStringUsingEncoding:NSUTF8StringEncoding]);
    int value = 0;
    for (int i = 0; i < strlen(buf)-1; i++) {                               // Test and set
        if (buf[i] == '1') (value |= 1);
        value <<= 1;                                                        // Shift and loop
    }
    return [NSNumber numberWithUnsignedShort:value];
}
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
    unsigned long *maxAddr = (unsigned long *)max;
    unsigned long *minAddr = (unsigned long *)min;
    unsigned long distance = (unsigned long)maxAddr - (unsigned long)minAddr;

    return (distance / factor);
}

/********************* NSString* binaryStringForValue() **********************
 
 name        : NSString* binaryStringForValue(unsigned short value)
 parameters  : unsigned short value : the number to be converted to a binary
               string representation
 function    : calculates the distance between pointers, with a size specified
 by size, either BYTE_MASK, WORD_MASK, or LONG_MASK.
 
 ****************************************************************************/
NSString* binaryStringForValue(unsigned short value) {
    int position = WORD68K;
    char buf[WORD68K+1];
    buf[position--] = '\0';
    do {
        if (value & 1) buf[position--] = '1';
            else buf[position--] = '0';
                value >>= 1;
                } while (value > 0);
    
    while (position >= 0) {
        buf[position--] = '0';
    }
    
    return [NSString stringWithFormat:@"%s",buf];
}
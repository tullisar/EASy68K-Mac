/***************************** 68000 SIMULATOR ****************************
 
 File Name: mac68kutils.h
 Version: 1.0 (Mac OS X)
 
 This file contains various routines and defines used in the Mac OS X port 
 of EASy68K.
 
 The routines are:
 memDistance
 
 Created:  2011-03-17
           Robert Bartlett-Schneider
 
 ***************************************************************************/

#define DISPATCH_MAIN_THREAD \
if (![NSThread isMainThread]) {\
    [self performSelectorOnMainThread:@selector(displayReg)\
                           withObject:nil\
                        waitUntilDone:NO];\
    return;\
}

long memDistance(void *max, void *min, long size);
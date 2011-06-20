/***********************************************************************
 *
 *		PLATFORM.CPP
 *		Platform specific function implementations for things that rely
 *      on *nix or win libraries. Since POSIX functions aren't guaranteed
 *      to exist under Windows.
 *
 *      Author: Robert Bartlett-Schneider
 *
 *        Date:	2011-06-18
 *
 ************************************************************************/

#include "platform.h"
#include <stdio.h>
#include <cstring>

char workPath[MAXPATHLEN];      // absolute reference to directory containing inFile
char includePath[MAXPATHLEN];   // absolute reference to include file, temp buffer

//------------------------------------------------------------
// establishPath()
// Establishes the absolute path to the directory in which the
// assembly file is located.
//------------------------------------------------------------
void establishPath(char *filePath) {
    char *pathPtr = filePath, *lastPtr;
    int i = 0;
    
    // Find last path separator
    do {
        lastPtr = pathPtr;
        pathPtr++;
        pathPtr = strchr(pathPtr, '/');
    } while (pathPtr);
    
    // Generate path string
    pathPtr = filePath;
    while (!(pathPtr == lastPtr))
        workPath[i++] = *(pathPtr++);
    workPath[i++] = '/';
    workPath[i++] = '\0';
}

//------------------------------------------------------------
// prependPath()
// Prepends the current working file path to a supplied string
//------------------------------------------------------------
void prependPath(char *filePath) {
    char buffer[MAXPATHLEN];
    sprintf(buffer, "%s%s", workPath, filePath);
    sprintf(filePath, "%s", buffer);
}

//------------------------------------------------------------
// errorPrint()
// Used for printing an error to a console or a window based
// on current platform.
//------------------------------------------------------------
void errorPrint(char *errMsg) {
#ifndef __COREFOUNDATION__
    printf("%s",errMsg);
#else
    NSLog(@"s",errMsg);
#endif
}

//------------------------------------------------------------
// getFixedTabSize()
// Gets the fixed tab size for listfile output depending on
// current OS implementation.
//------------------------------------------------------------
int getFixedTabSize() {
#ifndef __COREFOUNDATION__
    return 4; // TODO: Temporary for command line, perhaps implement as a parameter
#else
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud integerForKey:@"tabWidthInSpaces"];
#endif
}
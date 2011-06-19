/*
 *  platform.cpp
 *  Edit68K
 *
 *  Created by Robert Bartlett-Schneider on 6/18/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "platform.h"

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
    
    do {
        lastPtr = pathPtr;
        pathPtr++;
        pathPtr = strchr(pathPtr, '/');
    } while (pathPtr);
    
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
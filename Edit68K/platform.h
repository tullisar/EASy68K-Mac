/*
 *  platform.h
 *  Edit68K
 *
 *  Created by Robert Bartlett-Schneider on 5/23/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef MAC68K
#define MAC68K

#include <sys/param.h>

extern char workPath[MAXPATHLEN];
extern char includePath[MAXPATHLEN];
extern void establishPath(char *);
extern void prependPath(char *);

#endif
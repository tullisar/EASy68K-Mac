/***********************************************************************
 *
 *		PLATFORM.H
 *		Platform specific function implementations for things that rely
 *      on *nix or win libraries. Since POSIX functions aren't guaranteed
 *      to exist under Windows.
 *
 *      Author: Robert Bartlett-Schneider
 *
 *        Date:	2011-06-18
 *
 ************************************************************************/

#ifndef MAC68K
#define MAC68K

#include <sys/param.h>

extern char workPath[MAXPATHLEN];
extern char includePath[MAXPATHLEN];
extern void establishPath(char *);
extern void prependPath(char *);
extern void errorPrint(char *);
extern int getFixedTabSize();

#endif
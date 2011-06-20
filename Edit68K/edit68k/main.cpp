/***********************************************************************
 *
 *		MAIN.CPP
 *		Command line launcher for asm68k, based on the Unix 68K port by 
 *      Mark Wickens.
 *
 ************************************************************************/

#include <stdio.h>
#include <getopt.h>
#include "asm.h"

#define verbose 1

extern bool listFlag;
extern bool objFlag;
// extern bool binFlag;

int assembleFile(char fileName[], char tempName[], char workName[]);

int main(int argc, char **argv)
{
	int c;
	int digit_optind = 0;
    
	int verboseArg = false;
	int listArg = false;
	int objArg = false;
	int binArg = false;	
	char ifile[256];
	char sfile[256];
	char lfile[256];
	char bfile[256];
	char tfile[256];
	
	while (1)
	{
		static char *help = "\
        MC68000 Assembler v1.0, based on code from Easy68k v3.5 by Chuck Kelly/Paul McKee\n \
        ported by Mark Wickens 2006 <mark@wickensonline.co.uk>\n \
        Usage: asm68k [-l] [-s] [-b] [-h] [-v] <input>.X68\n \
        Options:	-l --listing	Generate listing file\n \
        -s --srecord	Generate Motorola S-Record output file,\n \
        -b --binary		Generate binary output file\n \
        -h --help		Display this help (doh!)\n \
        -v --verbose	Maximum verbosity\n";
        
		static struct option long_options[] = {
			{"verbose", no_argument, &verboseArg, 1},
			{"listing", no_argument, &listArg, 1},
			{"srecord", no_argument, &objArg, 1},
			{"binary", no_argument, &binArg, 1},
			{"help", no_argument, 0, 0},
			{0, 0, 0, 0}
		};
		int option_index = 0;
		
		c = getopt_long(argc, argv, "vlsbh", long_options, &option_index);
		
		// Detect end of options
		if (c == -1)
			break;
		
		switch(c) {
            case 0:
                /* If this option set a flag, do nothing else now. */
                if (long_options[option_index].flag != 0)
                    break;
                if (strcmp(long_options[option_index].name, "help") == 0)
                {
                    printf(help);
                    return 0;
                }
                else
                {
                    printf ("option %s", long_options[option_index].name);
                    if (optarg)
                        printf (" with arg %s", optarg);
                    printf ("\n");
                }
                break;
                
            case 'h':
                printf(help);
                return 0;
                break;
                
            case 'v':
                verboseArg = true;
                break;
                
            case 'l':
                listArg = true;
                break;
                
            case 's':
                objArg = true;
                break;
                
            case 'b':
                binArg = true;
                break;
                
            default:
                printf("?? getopt returned character code 0%o ??\n", c);
                abort();
		}
	}
	
	if (verboseArg)
	{
		printf("Verbose set\n", ifile);
		if (listArg)
		{
			printf("Listing output on\n");
		}
		if (objArg)
		{
			printf("S Record output on\n");
		}
		if (binArg)
		{
			printf("Binary output on\n");
		}
	}
    
	if (listArg)
	{
		listFlag = true;
	}
	if (objArg)
	{
		objFlag = true;
	}
	if (binArg)
	{
		// binFlag = true;
	}
	
	for (int i = optind; i < argc; i++)
	{
		strcpy(ifile, argv[i]);
		if (verboseArg)
		{
			printf("Processing input file %s\n", ifile);
		}
		strcpy(tfile, "asm68k-XXXXXX");
		if (mktemp(tfile) == NULL)
		{
			printf("Error creating temporary file via mkstemp() function\n");
			abort();
		}
        
		assembleFile(ifile, tfile, ifile);
		
		// Remove temporary file
		remove(tfile);
	}
	
	return 0;
}

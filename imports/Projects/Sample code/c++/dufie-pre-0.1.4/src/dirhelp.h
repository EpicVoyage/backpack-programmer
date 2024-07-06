/* Programmer:  Chris Umphress
 * Project:	Dufie
 * Date:	Jan 16, 2005
 * URL:		http://daga.dyndns.org/projects/dufie/
 *
 * Purpose:	To aid in sorting a directory tree
 */

#ifndef _dirhelp_h
#define _dirhelp_h

#include <string.h>
#include <assert.h>

typedef struct dirhelp
{
	char *dir;
	long size;
	
	struct dirhelp *next;
} DIRHELP;

void cleanup(DIRHELP *x);
void add(DIRHELP *main, char *d, long s);

#endif // _dirhelp_h

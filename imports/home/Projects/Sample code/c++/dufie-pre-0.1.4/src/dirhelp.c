/* Programmer:  Chris Umphress
 * Project:	Dufie
 * Date:	Jan 16, 2005
 * URL:		http://daga.dyndns.org/projects/dufie/
 *
 * Purpose:	To aid in sorting a directory tree
 */

#include "dirhelp.h"

/* free()'s all but the top-level item */
void cleanup(DIRHELP *x)
{
	if (x->next)
	{
		cleanup(x->next);
		free(x->next);
		x->next = NULL;
	}
	
	if (x->dir)
	{
		free(x->dir);
		x->dir = NULL;
	}
	
	return;
}

void add(DIRHELP *main, char *d, long s)
{
	DIRHELP *sub = main;
	char **path;
	long *sz;
	long x;

	while (sub->next)
		sub = sub->next;
	
	if (sub->dir)
	{
		sub->next = (DIRHELP *)malloc(sizeof(DIRHELP));
		assert(sub->next != NULL);

		sub = sub->next;
		sub->next = NULL;
	}

	sub->dir = (char *)malloc(strlen(d) + 1);
	assert(sub->dir != NULL);
	strcpy(sub->dir, d);

	sub->size = s;
	
	return;
}


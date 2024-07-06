/* Programmer:		Chris Umphress
 * Date begun:		1/6/05
 *
 * Purpose:
 *   To create a graphical program to show file usage.
 *   The programmers of the linux utility 'du' have
 *   written most of the required code, so this is just a
 *   GUI (DU Front [i] End).
 *
 * Comments:
 *   Yes, I let Glade generate this :P
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>
#include <strings.h>
#include <signal.h>

#include "interface.h"
#include "callbacks.h"
#include "support.h"

void print_help(char *progname);

int main(int argc, char *argv[])
{
	GtkWidget *wndMain;
	GtkWidget *wndSelect;
	char *path = NULL;
	int i;

	/* look for paths to calculate on startup, use the last one */
	for (i = 1; i < argc; i++)
	{
		if (*argv[i] != '-')
			path = argv[i];
		else if ((strcasecmp(argv[i], "--help") == 0) || (strcasecmp(argv[i], "-h") == 0))
		{
			print_help(argv[0]);
			return;
		}
	}

	/* Don't die when we see sigpipe */
	signal(SIGPIPE, (__sighandler_t)sig);

#ifdef ENABLE_NLS
	bindtextdomain(GETTEXT_PACKAGE, PACKAGE_LOCALE_DIR);
	bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
	textdomain(GETTEXT_PACKAGE);
#endif

	gtk_set_locale();
	gtk_init(&argc, &argv);

	add_pixmap_directory(PACKAGE_DATA_DIR "/" PACKAGE "/pixmaps");

	wndMain = create_wndMain(path);

	gtk_main();

	return 0;
}

void print_help(char *progname)
{
	printf("%s [--help|-h] [/path/to/directory]\n\n", progname);
	printf("  -h, --help       show this screen\n");
	printf("  /path/to/...     directory to load automatically\n");

	return;
}


#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

/*#define NDEBUG*/

#include <sys/types.h>
#include <sys/stat.h>
#include <gtk/gtk.h>
#include <strings.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

GtkStatusbar *status = NULL;

gint on_wndMain_init(gpointer data)
{	
	status = GTK_STATUSBAR(data);
	set_status_bar(NULL);

	return;
}

gboolean on_wndMain_close(GtkWidget *widget, GdkEvent *event, gpointer data)
{	
	/* closes the application after this function returns */
	gtk_main_quit();

	/* return FALSE so the window is destroyed */
	return FALSE;
}

gboolean on_wndAbout_close(GtkWidget *widget, GdkEvent *event, gpointer data)
{
	/* destroy window */
	return FALSE;
}

void on_mnuOpen_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* declare variables */
	char *filename = NULL;

	/* create an open dialog */
	GtkWindow *parent = GTK_WINDOW(GTK_WIDGET_TOPLEVEL(menuitem));

	/* and this function is where things go wrong -- but only under GDB */
	GtkWidget *open = gtk_file_chooser_dialog_new(_("Choose Directory"),
						      parent,
						      GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
						      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
						      GTK_STOCK_OPEN, GTK_RESPONSE_OK,
						      NULL);

	/* show window, and get the results */
	if (gtk_dialog_run(GTK_DIALOG(open)) == GTK_RESPONSE_OK)
		filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(open));

	/* move to processing the information */
	gtk_widget_destroy(open);

	/* if a directory was selected */
	if (filename)
		load_dir(filename, data);

	g_free(filename);

	return;
}

void on_mnuSlackPack_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* declare variables */
	GtkTreeIter  toplevel;
	GtkTreeStore *treestore;
	GtkTreeSortable *sortable;
	struct dirent *pkg;
	DIRHELP dir;
	char *filename = NULL,
	     *name,
	     *tmp;
	FILE *in;
	long indiv, cumul = 0;
	DIR *slacklist;
	int x = 0;

	/* create an open dialog */
	GtkWindow *parent = GTK_WINDOW(GTK_WIDGET_TOPLEVEL(menuitem));

	/* and this function is where things go wrong -- but only under GDB */
	GtkWidget *open = gtk_file_chooser_dialog_new(_("Slackware packages? /var/log/packages?"),
						      parent,
						      GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
						      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
						      GTK_STOCK_OPEN, GTK_RESPONSE_OK,
						      NULL);

	/* show window, and get the results */
	gtk_file_chooser_set_filename(GTK_FILE_CHOOSER(open), "/var/log/packages/");
	if (gtk_dialog_run(GTK_DIALOG(open)) == GTK_RESPONSE_OK)
		filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(open));

	/* move to processing the information */
	gtk_widget_destroy(open);

	/* if a directory was selected */
	if (filename)
	{
		/* more initialization */
		name = (char *)malloc(strlen(filename) + NAME_MAX + 2);
		tmp = (char *)malloc(2048);
		dir.next = NULL;
		dir.dir = NULL;
		dir.size = 0;
		
		/* open the working directory */
		slacklist = opendir(filename);

		/* read the names of files in the working directory */
		while (pkg = readdir(slacklist))
		{
			/* if the "file" refers to the current or parent directory, go to
			 * the next file
			 */
			if ((strcmp(pkg->d_name, ".") == 0) || (strcmp(pkg->d_name, "..") == 0))
				continue;

			if (strlen(pkg->d_name) < 2033)
			{
				sprintf(tmp, "Retrieving %s...", pkg->d_name);
				set_status_bar(tmp);
			}

			while (gtk_events_pending())
				gtk_main_iteration();
			
			/* patch together the filename so we can open it */
			strcpy(name, filename);
			strcat(name, "/");
			strcat(name, pkg->d_name);

			if (in = fopen(name, "r"))
			{
				/* look for the uncompressed package size in the logs */
				while (fgets(tmp, 2048, in))
				{
					if (strncasecmp(tmp, "UNCOMPRESSED PACKAGE SIZE:     ", 31) == 0)
						break;
					tmp[0] = 0;
				}
				fclose(in);

				/* definately a "hack" -- allows us to use existing functions
				 * to display information
				 */
				strcpy(name, "/");
				strcat(name, pkg->d_name);
			
				/* add to a linked list */
				if (*tmp)
				{
					indiv = atol(tmp + 31);
					add(&dir, name, indiv);
					cumul += indiv;
				}
			}
		}

		/* create a "root" element */
		add(&dir, "/", cumul);

		/* some quick cleanup */
		closedir(slacklist);

		set_status_bar("Arranging tree structure...");
		while (gtk_events_pending())
			gtk_main_iteration();

		/* create and fill the tree view data structure */
		treestore = gtk_tree_store_new(3, G_TYPE_LONG, GDK_TYPE_PIXBUF, G_TYPE_STRING);
		toplevel = create_file_tree(&dir, "/", treestore, NULL);

		/* set the tree view to the tree generated and expand the top-level item */
		sortable = GTK_TREE_SORTABLE(GTK_TREE_MODEL(treestore));
		gtk_tree_sortable_set_sort_column_id(sortable, 0, GTK_SORT_DESCENDING);
		gtk_tree_view_set_model(GTK_TREE_VIEW(data), GTK_TREE_MODEL(treestore));
		gtk_tree_view_expand_row(GTK_TREE_VIEW(data), gtk_tree_model_get_path(GTK_TREE_MODEL(treestore), &toplevel), FALSE);
		g_object_unref(GTK_TREE_MODEL(treestore));

		strcpy(tmp, "Loaded list of installed Slackware packages");
		set_status_bar(tmp);

		/* cleanup */
		free(tmp);
		cleanup(&dir);
		g_free(filename);
	}

	return;
}

void on_mnuRPM_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* declare variables */
	GtkTreeIter  toplevel;
	GtkTreeStore *treestore;
	GtkTreeSortable *sortable;
	DIRHELP dir;
	long indiv, cumul = 0;
	char *cmd = "rpm -qa --queryformat '%{size}\\t%{name}\\n'",
	     *name,
	     *tmp,
	     *ptr;
	FILE *cap;
	int x = 0;

	/* create an open dialog */
	GtkWindow *parent = GTK_WINDOW(GTK_WIDGET_TOPLEVEL(menuitem));

	/* more initialization */
	name = (char *)malloc(NAME_MAX + 2);
	tmp = (char *)malloc(2048);
	dir.next = NULL;
	dir.dir = NULL;
	dir.size = 0;
		
	/* execute rpm */
	cap = popen(cmd, "r");

	/* read output from du */
	while (fgets(tmp, 2048, cap))
	{
		/* split sizes from the directory names */
		ptr = strchr(tmp, 10); /* 10 == cr */
		if (ptr)
			*ptr = 0;
			
		ptr = strchr(tmp, 9); /* 9 == tab */
		if (ptr)
		{
			*ptr = 0;
			ptr++;
		}

		if (strlen(ptr) < 2033)
		{
			sprintf(name, "Processing %s...", ptr);
			set_status_bar(name);
		}

		while (gtk_events_pending())
			gtk_main_iteration();
		
		strcpy(name, "/");
		strcat(name, ptr);
		
		/* add to a linked list */
		if (*tmp)
		{
			indiv = atol(tmp) / 1024;
			add(&dir, name, indiv);
			cumul += indiv;
		}

		/* add to a linked list */
		add(&dir, ptr, atol(tmp));

		while (gtk_events_pending())
			gtk_main_iteration();
	}

	/* create a "root" element */
	add(&dir, "/", cumul);

	set_status_bar("Arranging tree structure...");
	while (gtk_events_pending())
		gtk_main_iteration();

	/* create and fill the tree view data structure */
	treestore = gtk_tree_store_new(3, G_TYPE_LONG, GDK_TYPE_PIXBUF, G_TYPE_STRING);
	toplevel = create_file_tree(&dir, "/", treestore, NULL);

	/* set the tree view to the tree generated and expand the top-level item */
	sortable = GTK_TREE_SORTABLE(GTK_TREE_MODEL(treestore));
	gtk_tree_sortable_set_sort_column_id(sortable, 0, GTK_SORT_DESCENDING);
	gtk_tree_view_set_model(GTK_TREE_VIEW(data), GTK_TREE_MODEL(treestore));
	gtk_tree_view_expand_row(GTK_TREE_VIEW(data), gtk_tree_model_get_path(GTK_TREE_MODEL(treestore), &toplevel), FALSE);
	g_object_unref(GTK_TREE_MODEL(treestore));

	sprintf(tmp, "Loaded list of installed RPMs...");
	set_status_bar(tmp);

	/* cleanup */
	pclose(cap);
	free(name);
	free(tmp);

	/* general cleanup */
	cleanup(&dir);

	return;
}

void on_mnuDebian_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* declare variables */
	GtkTreeIter  toplevel;
	GtkTreeStore *treestore;
	GtkTreeSortable *sortable;
	struct dirent *type, *pkg;
	struct stat stats;
	DIRHELP dir;
	char *filename = NULL,
	     *name,
	     *spec,
	     *tmp;
	FILE *in;
	long indiv, cumul = 0;
	int x = 0;

	/* create an open dialog */
	GtkWindow *parent = GTK_WINDOW(GTK_WIDGET_TOPLEVEL(menuitem));

	/* and this function is where things go wrong -- but only under GDB */
	GtkWidget *open = gtk_file_chooser_dialog_new(_("Portage packages? /var/lib/dpkg/status?"),
						      parent,
						      GTK_FILE_CHOOSER_ACTION_OPEN,
						      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
						      GTK_STOCK_OPEN, GTK_RESPONSE_OK,
						      NULL);

	/* show window, and get the results */
	gtk_file_chooser_set_filename(GTK_FILE_CHOOSER(open), "/var/lib/dpkg/status");
	if (gtk_dialog_run(GTK_DIALOG(open)) == GTK_RESPONSE_OK)
		filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(open));

	/* move to processing the information */
	gtk_widget_destroy(open);

	/* if a directory was selected */
	if (filename)
	{
		/* more initialization */
		tmp = (char *)malloc(2048);
		name = (char *)malloc(2048);
		spec = (char *)malloc(2048);

		/* just to be safe... */
		*name = 0;

		/* Open the file containing the package information */
		if (in = fopen(filename, "r"))
		{
			indiv = 0;

			/* read through the file line-by-line */
			while (fgets(tmp, 2048, in))
			{
				/* Lines that start with "Package: " change the name variable */
				if (strncasecmp(tmp, "Package: ", 9) == 0)
				{
					strcpy(name, tmp + 9);
					name[strlen(name) - 1] = 0;

					if (strlen(name) < 2033)
					{
						sprintf(spec, "Processing %s...", name);
						set_status_bar(spec);
					}

					while (gtk_events_pending())
						gtk_main_iteration();
				}
				/* "Installed-Size: " changes the size variable */
				else if (strncasecmp(tmp, "Installed-Size: ", 16) == 0)
				{
					indiv = atol(tmp + 16);
					cumul += indiv;
				}
				/* "Version: " adds the current name and size as a package */
				else if (strncasecmp(tmp, "Version: ", 9) == 0)
				{
					strcpy(spec, "/");
					strcat(spec, name);
					strcat(spec, ", ");
					strcat(spec, tmp + 9);
					spec[strlen(spec) - 1] = 0;

					add(&dir, spec, indiv);
				}
			}

			/* close up */
			fclose(in);
		}

		/* create a "root" element */
		add(&dir, "/", cumul);

		set_status_bar("Arranging tree structure...");
		while (gtk_events_pending())
			gtk_main_iteration();

		/* create and fill the tree view data structure */
		treestore = gtk_tree_store_new(3, G_TYPE_LONG, GDK_TYPE_PIXBUF, G_TYPE_STRING);
		toplevel = create_file_tree(&dir, "/", treestore, NULL);

		/* set the tree view to the tree generated and expand the top-level item */
		sortable = GTK_TREE_SORTABLE(GTK_TREE_MODEL(treestore));
		gtk_tree_sortable_set_sort_column_id(sortable, 0, GTK_SORT_DESCENDING);
		gtk_tree_view_set_model(GTK_TREE_VIEW(data), GTK_TREE_MODEL(treestore));
		gtk_tree_view_expand_row(GTK_TREE_VIEW(data), gtk_tree_model_get_path(GTK_TREE_MODEL(treestore), &toplevel), FALSE);
		g_object_unref(GTK_TREE_MODEL(treestore));

		strcpy(tmp, "Loaded list of installed Debian packages");
		set_status_bar(tmp);

		/* cleanup */
		free(tmp);
		free(name);
		free(spec);
		cleanup(&dir);
		g_free(filename);
	}

	return;
}

void on_mnuPortage_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* declare variables */
	GtkTreeIter  toplevel;
	GtkTreeStore *treestore;
	GtkTreeSortable *sortable;
	struct dirent *type, *pkg;
	struct stat stats;
	DIRHELP dir;
	char *filename = NULL,
	     *name,
	     *tok,
	     *tmp;
	FILE *in;
	long indiv, group, cumul = 0;
	DIR *pkgtype, *packages;
	int x = 0;

	/* create an open dialog */
	GtkWindow *parent = GTK_WINDOW(GTK_WIDGET_TOPLEVEL(menuitem));

	/* and this function is where things go wrong -- but only under GDB */
	GtkWidget *open = gtk_file_chooser_dialog_new(_("Portage packages? /var/db/pkg?"),
						      parent,
						      GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
						      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
						      GTK_STOCK_OPEN, GTK_RESPONSE_OK,
						      NULL);

	/* show window, and get the results */
	gtk_file_chooser_set_filename(GTK_FILE_CHOOSER(open), "/var/db/pkg/");
	if (gtk_dialog_run(GTK_DIALOG(open)) == GTK_RESPONSE_OK)
		filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(open));

	/* move to processing the information */
	gtk_widget_destroy(open);

	/* if a directory was selected */
	if (filename)
	{
		/* more initialization */
		name = (char *)malloc(strlen(filename) + NAME_MAX + 2);
		tmp = (char *)malloc(2048);
		dir.next = NULL;
		dir.dir = NULL;
		dir.size = 0;
		
		/* open the working directory */
		pkgtype = opendir(filename);

		/* read the names of files (package types) in the working directory */
		while (type = readdir(pkgtype))
		{
			/* if the "file" refers to the current or parent directory, go to
			 * the next file
			 */
			if ((strcmp(type->d_name, ".") == 0) || (strcmp(type->d_name, "..") == 0))
				continue;

			/* reset group size indicator */
			group = 0;
			
			/* open a new working directory */
			strcpy(name, filename);
			strcat(name, "/");
			strcat(name, type->d_name);
			packages = opendir(name);

			/* read the names of the files (packages) in the working directory */
			while ((packages != NULL) && (pkg = readdir(packages)))
			{
				if (strlen(pkg->d_name) < strlen(filename) + NAME_MAX - 12)
				{
					sprintf(name, "Processing %s...", pkg->d_name);
					set_status_bar(name);
				}

				while (gtk_events_pending())
					gtk_main_iteration();
			
				/* patch together the filename so we can open it */
				strcpy(name, filename);
				strcat(name, "/");
				strcat(name, type->d_name);
				strcat(name, "/");
				strcat(name, pkg->d_name);
				strcat(name, "/CONTENTS");

				if (in = fopen(name, "r"))
				{
					/* look for the uncompressed package size in the logs */
					indiv = 0;
					while (fgets(tmp, 2048, in))
					{
						if (strncasecmp(tmp, "obj", 3) == 0)
						{
							tok = strchr(tmp + 4, 32);
							if (tok)
							{
								*tok = 0;
								if (stat(tmp + 4, &stats))
									continue;

								indiv += (stats.st_size / 1024);
							}
						}
						tmp[0] = 0;
					}
					fclose(in);

					/* increment group and total file sizes */
					group += indiv;
					cumul += indiv;

					/* definately a "hack" -- allows us to use existing functions
					 * to display information
					 */
					strcpy(name, "/");
					strcat(name, type->d_name);
					strcat(name, "/");
					strcat(name, pkg->d_name);
			
					/* add to a linked list */
					add(&dir, name, indiv);
				}

				while (gtk_events_pending())
					gtk_main_iteration();
			}

			strcpy(name, "/");
			strcat(name, type->d_name);
			add(&dir, name, group);

			/* some quick cleanup */
			closedir(packages);
		}

		/* create a "root" element */
		add(&dir, "/", cumul);

		/* some quick cleanup */
		closedir(pkgtype);

		set_status_bar("Arranging tree structure...");
		while (gtk_events_pending())
			gtk_main_iteration();

		/* create and fill the tree view data structure */
		treestore = gtk_tree_store_new(3, G_TYPE_LONG, GDK_TYPE_PIXBUF, G_TYPE_STRING);
		toplevel = create_file_tree(&dir, "/", treestore, NULL);

		/* set the tree view to the tree generated and expand the top-level item */
		sortable = GTK_TREE_SORTABLE(GTK_TREE_MODEL(treestore));
		gtk_tree_sortable_set_sort_column_id(sortable, 0, GTK_SORT_DESCENDING);
		gtk_tree_view_set_model(GTK_TREE_VIEW(data), GTK_TREE_MODEL(treestore));
		gtk_tree_view_expand_row(GTK_TREE_VIEW(data), gtk_tree_model_get_path(GTK_TREE_MODEL(treestore), &toplevel), FALSE);
		g_object_unref(GTK_TREE_MODEL(treestore));

		strcpy(tmp, "Loaded list of installed Portage packages");
		set_status_bar(tmp);

		/* cleanup */
		free(tmp);
		cleanup(&dir);
		g_free(filename);
	}

	return;
}

void on_quit1_activate(GtkMenuItem *menuitem, gpointer data)
{
	/* main loop will be terminated A.S.A.P. */
	gtk_main_quit();
	
	return;
}


void on_about1_activate(GtkMenuItem *menuitem, gpointer data)
{
	GtkWidget *about = create_wndAbout();
	gtk_widget_show(about);

	return;
}

/* Maybe later this function will load the output from 'df'... maybe */
GtkTreeModel *create_initial_tree()
{
	GtkTreeStore *treestore;
	GtkTreeIter   toplevel;

	treestore = gtk_tree_store_new(3, G_TYPE_STRING, GDK_TYPE_PIXBUF, G_TYPE_STRING);

	gtk_tree_store_append(treestore, &toplevel, NULL);
	gtk_tree_store_set(treestore, &toplevel, 0, "", 1, NULL, 2, "To begin select File -> Open", -1);

	return GTK_TREE_MODEL(treestore);
}

GtkTreeIter create_file_tree(DIRHELP *dir, char *path, GtkTreeStore *treestore, GtkTreeIter *parent)
{
	DIRHELP *sub = dir;
	GtkTreeIter child;
	char *out, *size;
	int x, y;
	
	while ((sub->next) || ((parent == NULL) && (sub->dir)))
	{
		/* cheap way to see if sub->dir starts with path */
		x = 0;
		y = strlen(path);
		while ((path[x]) && (sub->dir[x] == path[x])) x++;
		
		/* if path starts off sub->dir */
		if (x == y)
		{
			/* if this is the top-level element */
			if (parent == NULL)
			{
				/* if sub->dir matches path exactly */
				if (sub->dir[x] == 0)
				{
					out = (char *)malloc(strlen(sub->dir) + 14);
					size = (char *)malloc(12);
					readable(sub->size, size);

					sprintf(out, "%s (%s)", sub->dir, size);
					
					gtk_tree_store_append(treestore, &child, NULL);
					gtk_tree_store_set(treestore, &child, 0, sub->size, 1, NULL, 2, out, -1);

					free(size);
					free(out);
					
					create_file_tree(dir, sub->dir, treestore, &child);
					break;
				}
			}
			/* otherwise, if there is a parent, there is a slash right after the limit
			 * where it matched path (prevent test/ and test-hi/ from appearing the same)
			 * and that there are no extra /'s after that one.
			 * OR it is the root (/) directory and there are no more slashes.
			 */
			else if (((sub->dir[x] == '/') && (strchr(sub->dir + x + 1, '/') == NULL)) ||
			        ((x == 1) && (strchr(sub->dir + 1, '/') == NULL)))
			{
				if (x == 1) x--;

				out = (char *)malloc(strlen(sub->dir + x + 1) + 14); /* for <dir> + " (<size>)\x00" */
				size = (char *)malloc(12);
				readable(sub->size, size);
				
				gtk_tree_store_append(treestore, &child, parent);
				sprintf(out, "%s (%s)", sub->dir + x + 1, size);
				gtk_tree_store_set(treestore, &child, 0, sub->size, 1, NULL, 2, out, -1);

				free(size);
				free(out);

				create_file_tree(dir, sub->dir, treestore, &child);
			}
		}

		if (sub->next) sub = sub->next;
	}

	return child;
}

void load_dir(char *path, gpointer data)
{
	/* declare variables */
	GtkTreeIter toplevel;
	GtkTreeStore *treestore;
	GtkTreeSortable *sortable;
	DIRHELP dir;
	char *cmd = NULL,
	     *tmp,
	     *ptr,
	     *bar;
	FILE *cap;
	int x = 0;

	/* sanitize filename for characters which mess with the
	 * shell's interepretation of things
	 */
	ptr = sanitize(path);
	
	/* more initialization */
	cmd = (char *)malloc(strlen(ptr) + 16);
	tmp = (char *)malloc(2048);
	bar = (char *)malloc(2048);
	*bar = 0;
	dir.next = NULL;
	dir.dir = NULL;
	dir.size = 0;

	/* execute du */
	strcpy(cmd, "du ");
	strcat(cmd, ptr);
	strcat(cmd, " 2>/dev/null");
	free(ptr);
	cap = popen(cmd, "r");

	if (!cap)
	{
		set_status_bar("Error when attempting to fork or open a pipe.");
		return;
	}

	/* read output from du */
	while (fgets(tmp, 2048, cap))
	{
		/* split sizes from the directory names */
		ptr = strchr(tmp, 10); /* 10 == cr */
		if (ptr)
			*ptr = 0;
			
		ptr = strchr(tmp, 9); /* 9 == tab */
		if (ptr)
		{
			*ptr = 0;
			ptr++;
		}

		/* show what directory we're on right now */
		if (strlen(bar) < 2036)
		{
			sprintf(bar, "Working on %s", ptr);
			set_status_bar(bar);
		}

		while (gtk_events_pending())
			gtk_main_iteration();

		/* add to a linked list */
		add(&dir, ptr, atol(tmp));
	}

	set_status_bar("Arranging tree structure...");
	while (gtk_events_pending())
		gtk_main_iteration();

	/* create and fill the tree view data structure */
	treestore = gtk_tree_store_new(3, G_TYPE_LONG, GDK_TYPE_PIXBUF, G_TYPE_STRING);
	toplevel = create_file_tree(&dir, path, treestore, NULL);

	/* set the tree view to the tree generated and expand the top-level item */
	sortable = GTK_TREE_SORTABLE(GTK_TREE_MODEL(treestore));
	gtk_tree_sortable_set_sort_column_id(sortable, 0, GTK_SORT_DESCENDING);
	gtk_tree_view_set_model(GTK_TREE_VIEW(data), GTK_TREE_MODEL(treestore));
	gtk_tree_view_expand_row(GTK_TREE_VIEW(data), gtk_tree_model_get_path(GTK_TREE_MODEL(treestore), &toplevel), FALSE);
	g_object_unref(GTK_TREE_MODEL(treestore));

	sprintf(tmp, "Loaded %s", path);
	set_status_bar(tmp);

	/* cleanup */
	pclose(cap);
	free(bar);
	free(tmp);
	free(cmd);
	cleanup(&dir);

	return;
}

void set_status_bar(char *text)
{
	int context;

	assert(status != NULL);

	context = GPOINTER_TO_INT(gtk_statusbar_get_context_id(GTK_STATUSBAR(status), "stsBar1"));
	gtk_statusbar_pop(GTK_STATUSBAR(status), context);

	if (text)
		gtk_statusbar_push(GTK_STATUSBAR(status), context, text);
	
	return;
}

void readable(long num, char *str)
{
	int type = 0;			/* KB, default */
	double tmp;

	if (num >= 1000000000)
	{
		tmp = num / 1073741824.0;
		type = 3;
	}
	else if (num >= 1000000)
	{
		tmp = num / 1048576.0;
		type = 2;
	}
	else if (num >= 1000)
	{
		tmp = num / 1024.0;
		type = 1;
	}
	else
		tmp = num;

	(type) ? sprintf(str, "%.1f", tmp) : sprintf(str, "%.0f", tmp);

	if (type == 3)
		strcat(str, "TB");
	else if (type == 2)
		strcat(str, "GB");
	else if (type == 1)
		strcat(str, "MB");
	else
		strcat(str, "KB");

	return;
}

char *sanitize(char *filename)
{
	/* declare variables */
	char *ret;
	char clean[256];
	long x, y = 0;
	
	/* clear array of characters to sanitize */
	for (x = 0; x < 256; x++)
		clean[x] = 0;
	
	/* enable sanitation of certain characters */
	clean['`'] = 1;
	clean['\"'] = 1;

	/* find out how large to make the buffer */
	for (x = 0; filename[x]; x++)
	{
		if (clean[filename[x]])
			y++;
	}

	/* create the buffer */
	ret = (char *)malloc(strlen(filename) + y + 3);

	/* re-initialize some variables and start the new filename with a quote */
	x = -1;
	y = 1;
	ret[0] = '"';

	/* loops through the string, copying each character. Modifies as neccessary */
	while (filename[++x])
	{
		if (clean[filename[x]])
		{
			ret[x + y] = '\\';
			y++;
		}
		
		ret[x + y] = filename[x];
	}

	/* close string with a quote and a NULL character */
	ret[x + y] = '"';
	ret[x + y + 1] = 0;
	
	return ret;
}

void sig(int s)
{
	return;
}


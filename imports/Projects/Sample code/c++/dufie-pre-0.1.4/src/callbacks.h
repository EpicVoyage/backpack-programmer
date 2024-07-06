#include <gtk/gtk.h>
#include "dirhelp.h"

gint on_wndMain_init(gpointer data);

gboolean on_wndMain_close(GtkWidget *widget, GdkEvent *event, gpointer data);
gboolean on_wndAbout_close(GtkWidget *widget, GdkEvent *event, gpointer data);

void on_mnuOpen_activate(GtkMenuItem *menuitem, gpointer data);
void on_quit1_activate(GtkMenuItem *menuitem, gpointer data);
void on_mnuSlackPack_activate(GtkMenuItem *menuitem, gpointer data);
void on_mnuRPM_activate(GtkMenuItem *menuitem, gpointer data);
void on_mnuDebian_activate(GtkMenuItem *menuitem, gpointer data);
void on_mnuPortage_activate(GtkMenuItem *menuitem, gpointer data);
void on_about1_activate(GtkMenuItem *menuitem, gpointer data);

GtkTreeModel *create_initial_tree();
GtkTreeIter create_file_tree(DIRHELP *dir, char *path, GtkTreeStore *treestore, GtkTreeIter *parent);

void load_dir(char *path, gpointer data);
void set_status_bar(char *text);
void readable(long num, char *str);
char *sanitize(char *filename);
void sig(int s);

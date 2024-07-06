/*
 * OK, this file has been editted. It's not a really good
 *  idea to re-run Glade at this point.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

#define GLADE_HOOKUP_OBJECT(component,widget,name) \
  g_object_set_data_full(G_OBJECT(component), name, \
    gtk_widget_ref(widget),(GDestroyNotify) gtk_widget_unref)

#define GLADE_HOOKUP_OBJECT_NO_REF(component,widget,name) \
  g_object_set_data(G_OBJECT(component), name, widget)

GtkWidget* create_wndMain(char *path)
{
  /* Create variables */
  GtkWidget *wndMain;
  GtkWidget *vbox1;
  GtkWidget *mnuMain;
  GtkWidget *mnuFile;
  GtkWidget *mnuFile_menu;
  GtkWidget *mnuOpen;
  GtkWidget *mnuSeparator1;
  GtkWidget *mnuQuit;
  GtkWidget *mnuSpecial;
  GtkWidget *mnuSpecial_menu;
  GtkWidget *mnuSlackPack;
  GtkWidget *mnuRPM;
  GtkWidget *mnuDebian;
  GtkWidget *mnuPortage;
  GtkWidget *mnuHelp;
  GtkWidget *mnuHelp_menu;
  GtkWidget *mnuAbout;
  GtkWidget *tbrMain;
  gint tmp_toolbar_icon_size;
  GtkWidget *wndScroll1;
  GtkWidget *tvwMain;
  GtkTreeViewColumn *col;
  GtkCellRenderer   *renderer;
  GtkTreeModel      *model;
  GtkWidget *stsBar1;
  GtkImage  *icnMain;
  GtkAccelGroup *accel_group;
  gchar *icon;

  /* Try to set up pixmap directories */
  add_pixmap_directory(PACKAGE_DATA_DIR "/pixmaps");
  /* add_pixmap_directory(PACKAGE_SOURCE_DIR "/pixmaps"); */
  accel_group = gtk_accel_group_new();

  icon = find_pixmap_file("dufie-icon.png");

  /* create the main window */
  wndMain = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_name(wndMain, "wndMain");
  gtk_window_set_title(GTK_WINDOW(wndMain), _("Dufie v" VERSION));
  gtk_window_set_default_size(GTK_WINDOW(wndMain), 390, 450);
  gtk_window_set_destroy_with_parent(GTK_WINDOW(wndMain), TRUE);
  if (icon)
  	gtk_window_set_icon_from_file(GTK_WINDOW(wndMain), icon, NULL);

  vbox1 = gtk_vbox_new(FALSE, 0);
  gtk_widget_set_name(vbox1, "vbox1");
  gtk_widget_show(vbox1);
  gtk_container_add(GTK_CONTAINER(wndMain), vbox1);

  /* create the menu bar */
  mnuMain = gtk_menu_bar_new();
  gtk_widget_set_name(mnuMain, "mnuMain");
  gtk_widget_show(mnuMain);
  gtk_box_pack_start(GTK_BOX(vbox1), mnuMain, FALSE, FALSE, 0);

  /* File menu */
  mnuFile = gtk_menu_item_new_with_mnemonic(_("_File"));
  gtk_widget_set_name(mnuFile, "mnuFile");
  gtk_widget_show(mnuFile);
  gtk_container_add(GTK_CONTAINER(mnuMain), mnuFile);

  mnuFile_menu = gtk_menu_new();
  gtk_widget_set_name(mnuFile_menu, "mnuFile_menu");
  gtk_menu_item_set_submenu(GTK_MENU_ITEM(mnuFile), mnuFile_menu);

  mnuOpen = gtk_image_menu_item_new_from_stock("gtk-open", accel_group);
  gtk_widget_set_name(mnuOpen, "mnuOpen");
  gtk_widget_show(mnuOpen);
  gtk_container_add(GTK_CONTAINER(mnuFile_menu), mnuOpen);

  mnuSeparator1 = gtk_separator_menu_item_new();
  gtk_widget_set_name(mnuSeparator1, "mnuSeparator1");
  gtk_widget_show(mnuSeparator1);
  gtk_container_add(GTK_CONTAINER(mnuFile_menu), mnuSeparator1);
  gtk_widget_set_sensitive(mnuSeparator1, FALSE);

  mnuQuit = gtk_image_menu_item_new_from_stock("gtk-quit", accel_group);
  gtk_widget_set_name(mnuQuit, "mnuQuit");
  gtk_widget_show(mnuQuit);
  gtk_container_add(GTK_CONTAINER(mnuFile_menu), mnuQuit);

  /* "Special" menu */
  mnuSpecial = gtk_menu_item_new_with_mnemonic(_("_Special"));
  gtk_widget_set_name(mnuSpecial, "mnuSpecial");
  gtk_widget_show(mnuSpecial);
  gtk_container_add(GTK_CONTAINER(mnuMain), mnuSpecial);

  mnuSpecial_menu = gtk_menu_new();
  gtk_widget_set_name(mnuSpecial_menu, "mnuSpecial_menu");
  gtk_menu_item_set_submenu(GTK_MENU_ITEM(mnuSpecial), mnuSpecial_menu);

  mnuSlackPack = gtk_menu_item_new_with_mnemonic(_("_Slackware Packages"));
  gtk_widget_set_name(mnuSlackPack, "mnuSlackPack");
  gtk_widget_show(mnuSlackPack);
  gtk_container_add(GTK_CONTAINER(mnuSpecial_menu), mnuSlackPack);

  mnuRPM = gtk_menu_item_new_with_mnemonic(_("_RPM Packages"));
  gtk_widget_set_name(mnuRPM, "mnuRPM");
  gtk_widget_show(mnuRPM);
  gtk_container_add(GTK_CONTAINER(mnuSpecial_menu), mnuRPM);

  mnuDebian = gtk_menu_item_new_with_mnemonic(_("_Debian Packages"));
  gtk_widget_set_name(mnuDebian, "mnuDebian");
  gtk_widget_show(mnuDebian);
  gtk_container_add(GTK_CONTAINER(mnuSpecial_menu), mnuDebian);

  mnuPortage = gtk_menu_item_new_with_mnemonic(_("_Portage Packages"));
  gtk_widget_set_name(mnuPortage, "mnuPortage");
  gtk_widget_show(mnuPortage);
  gtk_container_add(GTK_CONTAINER(mnuSpecial_menu), mnuPortage);
  
  /* Help menu */
  mnuHelp = gtk_menu_item_new_with_mnemonic(_("_Help"));
  gtk_widget_set_name(mnuHelp, "mnuHelp");
  gtk_widget_show(mnuHelp);
  gtk_container_add(GTK_CONTAINER(mnuMain), mnuHelp);

  mnuHelp_menu = gtk_menu_new();
  gtk_widget_set_name(mnuHelp_menu, "mnuHelp_menu");
  gtk_menu_item_set_submenu(GTK_MENU_ITEM(mnuHelp), mnuHelp_menu);

  mnuAbout = gtk_image_menu_item_new_from_stock("gtk-about", accel_group);
  gtk_widget_set_name(mnuAbout, "mnuAbout");
  gtk_widget_show(mnuAbout);
  gtk_container_add(GTK_CONTAINER(mnuHelp_menu), mnuAbout);

  /* Create a toolbar (er... yeah, isn't exactly used right now) */
  tbrMain = gtk_toolbar_new();
  gtk_widget_set_name(tbrMain, "tbrMain");
  gtk_widget_show(tbrMain);
  gtk_box_pack_start(GTK_BOX(vbox1), tbrMain, FALSE, FALSE, 0);
  gtk_toolbar_set_style(GTK_TOOLBAR(tbrMain), GTK_TOOLBAR_BOTH_HORIZ);
  tmp_toolbar_icon_size = gtk_toolbar_get_icon_size(GTK_TOOLBAR(tbrMain));

  /* create a scrolling tree view */
  wndScroll1 = gtk_scrolled_window_new(NULL, NULL);
  gtk_widget_set_name(wndScroll1, "wndScroll1");
  gtk_widget_show(wndScroll1);
  gtk_box_pack_start(GTK_BOX(vbox1), wndScroll1, TRUE, TRUE, 0);
  gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(wndScroll1), GTK_POLICY_AUTOMATIC, GTK_POLICY_ALWAYS);

  tvwMain = gtk_tree_view_new();
  gtk_widget_set_name(tvwMain, "tvwMain");
  gtk_widget_show(tvwMain);
  gtk_container_add(GTK_CONTAINER(wndScroll1), tvwMain);
  GTK_WIDGET_SET_FLAGS(tvwMain, GTK_CAN_DEFAULT);
  gtk_tree_view_set_reorderable(GTK_TREE_VIEW(tvwMain), TRUE);

  /* first column (invisible) */
  col = gtk_tree_view_column_new();
  gtk_tree_view_column_set_title(col, "Size in KB");
  gtk_tree_view_append_column(GTK_TREE_VIEW(tvwMain), col);

  renderer = gtk_cell_renderer_text_new();
  gtk_tree_view_column_pack_start(col, renderer, TRUE);
  gtk_tree_view_column_add_attribute(col, renderer, "text", 0);
  /*gtk_tree_view_column_set_resizable(col, 1);*/
  gtk_tree_view_column_set_visible(col, 0);
  
  gtk_tree_view_column_set_sort_column_id(col, 0);

  /* second column: bar meter and data */
  col = gtk_tree_view_column_new();
  gtk_tree_view_column_set_title(col, "Directory");
  gtk_tree_view_append_column(GTK_TREE_VIEW(tvwMain), col);

  renderer = gtk_cell_renderer_pixbuf_new();
  gtk_tree_view_column_pack_start(col, renderer, FALSE);
  gtk_tree_view_column_add_attribute(col, renderer, "pixbuf", 1);
  
  renderer = gtk_cell_renderer_text_new();
  gtk_tree_view_column_pack_start(col, renderer, TRUE);
  gtk_tree_view_column_add_attribute(col, renderer, "text", 2);

  g_object_set(renderer, "text", "loading...", NULL);

  model = create_initial_tree();
  gtk_tree_view_set_model(GTK_TREE_VIEW(tvwMain), model);

  /* status bar */
  stsBar1 = gtk_statusbar_new();
  gtk_widget_set_name(stsBar1, "stsBar1");
  gtk_widget_show(stsBar1);
  gtk_statusbar_push(GTK_STATUSBAR(stsBar1), gtk_statusbar_get_context_id(GTK_STATUSBAR(stsBar1), "stsBar1"), "loading...");
  gtk_box_pack_start(GTK_BOX(vbox1), stsBar1, FALSE, TRUE, 0);

  /*gtk_init_add(on_wndMain_init, stsBar1);*/
  g_signal_connect(GTK_OBJECT(wndMain), "delete_event", GTK_SIGNAL_FUNC(on_wndMain_close), NULL);

  g_signal_connect((gpointer)mnuOpen, "activate", G_CALLBACK(on_mnuOpen_activate), tvwMain);
  g_signal_connect((gpointer)mnuQuit, "activate", G_CALLBACK(on_quit1_activate), NULL);
  g_signal_connect((gpointer)mnuSlackPack, "activate", G_CALLBACK(on_mnuSlackPack_activate), tvwMain);
  g_signal_connect((gpointer)mnuRPM, "activate", G_CALLBACK(on_mnuRPM_activate), tvwMain);
  g_signal_connect((gpointer)mnuDebian, "activate", G_CALLBACK(on_mnuDebian_activate), tvwMain);
  g_signal_connect((gpointer)mnuPortage, "activate", G_CALLBACK(on_mnuPortage_activate), tvwMain);
  g_signal_connect((gpointer)mnuAbout, "activate", G_CALLBACK(on_about1_activate), NULL);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF(wndMain, wndMain, "wndMain");
  GLADE_HOOKUP_OBJECT(wndMain, vbox1, "vbox1");
  GLADE_HOOKUP_OBJECT(wndMain, mnuMain, "mnuMain");
  GLADE_HOOKUP_OBJECT(wndMain, mnuFile, "mnuFile");
  GLADE_HOOKUP_OBJECT(wndMain, mnuFile_menu, "mnuFile_menu");
  GLADE_HOOKUP_OBJECT(wndMain, mnuOpen, "mnuOpen");
  GLADE_HOOKUP_OBJECT(wndMain, mnuSeparator1, "mnuSeparator1");
  GLADE_HOOKUP_OBJECT(wndMain, mnuQuit, "mnuQuit");
  GLADE_HOOKUP_OBJECT(wndMain, mnuSpecial, "mnuSpecial");
  GLADE_HOOKUP_OBJECT(wndMain, mnuSpecial_menu, "mnuSpecial_menu");
  GLADE_HOOKUP_OBJECT(wndMain, mnuSlackPack, "mnuSlackPack");
  GLADE_HOOKUP_OBJECT(wndMain, mnuRPM, "mnuRPM");
  GLADE_HOOKUP_OBJECT(wndMain, mnuPortage, "mnuPortage");
  GLADE_HOOKUP_OBJECT(wndMain, mnuHelp, "mnuHelp");
  GLADE_HOOKUP_OBJECT(wndMain, mnuHelp_menu, "mnuHelp_menu");
  GLADE_HOOKUP_OBJECT(wndMain, mnuAbout, "mnuAbout");
  GLADE_HOOKUP_OBJECT(wndMain, tbrMain, "tbrMain");
  GLADE_HOOKUP_OBJECT(wndMain, wndScroll1, "wndScroll1");
  GLADE_HOOKUP_OBJECT(wndMain, tvwMain, "tvwMain");
  GLADE_HOOKUP_OBJECT(wndMain, stsBar1, "stsBar1");

  g_object_unref(model);

  gtk_widget_grab_default(tvwMain);
  gtk_window_add_accel_group(GTK_WINDOW(wndMain), accel_group);

  gtk_widget_show(wndMain);
  while (gtk_events_pending())
	gtk_main_iteration();
  on_wndMain_init(stsBar1);
  if (path != NULL)
  	load_dir(path, tvwMain);

  return wndMain;
}

GtkWidget *create_wndAbout(void)
{
  GtkWidget *wndAbout;
  GtkWidget *vbox2;
  GtkWidget *hbox2;
  GtkWidget *hbox3;
  GtkWidget *imgAbout;
  GtkWidget *lblAbout;
  GtkWidget *btnClose;

  gchar *icon;
  
  icon = find_pixmap_file("dufie-icon.png");

  wndAbout = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_name(wndAbout, "wndAbout");
  gtk_window_set_title(GTK_WINDOW(wndAbout), _("About " PACKAGE "..."));
  gtk_window_set_position(GTK_WINDOW(wndAbout), GTK_WIN_POS_CENTER_ON_PARENT);
  gtk_window_set_modal(GTK_WINDOW(wndAbout), TRUE);
  gtk_window_set_destroy_with_parent(GTK_WINDOW(wndAbout), TRUE);
  gtk_window_set_skip_taskbar_hint(GTK_WINDOW(wndAbout), TRUE);
  gtk_window_set_type_hint(GTK_WINDOW(wndAbout), GDK_WINDOW_TYPE_HINT_DIALOG);
  if (icon)
  	gtk_window_set_icon_from_file(GTK_WINDOW(wndAbout), icon, NULL);

  vbox2 = gtk_vbox_new(FALSE, 0);
  gtk_widget_set_name(vbox2, "vbox2");
  gtk_widget_show(vbox2);
  gtk_container_add(GTK_CONTAINER(wndAbout), vbox2);

  hbox2 = gtk_hbox_new(FALSE, 0);
  gtk_widget_set_name(hbox2, "hbox2");
  gtk_widget_show(hbox2);
  gtk_box_pack_start(GTK_BOX(vbox2), hbox2, FALSE, TRUE, 2);

  imgAbout = gtk_image_new_from_file(find_pixmap_file("dufie-logo.png"));
  gtk_widget_set_name(imgAbout, "imgAbout");
  gtk_widget_show(imgAbout);
  gtk_box_pack_start(GTK_BOX(hbox2), imgAbout, FALSE, TRUE, 2);

  lblAbout = gtk_label_new(_("\nDufie v" VERSION "\n\n"
  			    "The DU Front [i] End. A graphical representation of which\n"
			    "directories are using the most space.\n\n"
			    "Website:\t\thttp://daga.dyndns.org/projects/dufie/\n\n"
			    "Dufie v" VERSION " copyright (C) 2005 Daga\n\n"));
  gtk_widget_set_name(lblAbout, "lblAbout");
  gtk_widget_show(lblAbout);
  gtk_box_pack_start(GTK_BOX(vbox2), lblAbout, FALSE, TRUE, 3);

  hbox3 = gtk_hbox_new(FALSE, 0);
  gtk_widget_set_name(hbox3, "hbox3");
  gtk_widget_show(hbox3);
  gtk_box_pack_start(GTK_BOX(vbox2), hbox3, FALSE, TRUE, 5);

  btnClose = gtk_button_new_from_stock(GTK_STOCK_CLOSE);
  gtk_widget_set_name(btnClose, "btnClose");
  gtk_widget_show(btnClose);
  gtk_box_pack_start(GTK_BOX(hbox3), btnClose, TRUE, FALSE, 1);

  g_signal_connect(GTK_OBJECT(wndAbout), "delete_event", GTK_SIGNAL_FUNC(on_wndAbout_close), NULL);
  g_signal_connect_swapped(GTK_OBJECT(btnClose), "clicked", G_CALLBACK(gtk_object_destroy), wndAbout);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF(wndAbout, wndAbout, "wndAbout");
  GLADE_HOOKUP_OBJECT(wndAbout, vbox2, "vbox2");
  GLADE_HOOKUP_OBJECT(wndAbout, hbox2, "hbox2");
  GLADE_HOOKUP_OBJECT(wndAbout, hbox3, "hbox3");
  GLADE_HOOKUP_OBJECT(wndAbout, imgAbout, "imgAbout");
  GLADE_HOOKUP_OBJECT(wndAbout, lblAbout, "lblAbout");
  GLADE_HOOKUP_OBJECT(wndAbout, btnClose, "btnClose");

  return wndAbout;
}


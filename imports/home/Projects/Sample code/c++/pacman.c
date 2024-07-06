/* Author:	Daga <daga@daga.dyndns.org>
 * License:	GPL v2
 * Challenge:	Create a Pac-Man game in <= 20 minutes
 *
 * Start time:	1:48AM
 * End time:	4:36AM
 *
 * Result:	Failed the time test miserably ;)
 *
 * Compile:	gcc -o pacman pacman.c
 */

#include <sys/select.h>
#include <termio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

struct ghoul
{
	int x, y;
	int eaten;
};

/* declare some function names so we can call them from main() */
void set_keypress();
void reset_keypress();
void init();
void next();

/* some global variables */
fd_set rd;
char map[10][21];
struct ghoul ghouls[20];
struct termios stored_settings;
int ghosts, level, play, supermode, points;

int main()
{
	int ch, i;
	struct timeval tv;

	set_keypress();
	srand(time(NULL));
	play = 1;

	while (play)
	{
		points = 0;
		ghosts = 3;
		level = 1;
		init();

		while (play)
		{
			FD_ZERO(&rd);
			FD_SET(0, &rd);
			
			tv.tv_usec = 0;
			tv.tv_sec = 1;

			ch = select(1, &rd, NULL, NULL, &tv);

			if (ch != -1)
				next();

			if (ghouls[0].eaten == 1)
				play = 0;

			for (i = 0; map[0][i]; i++)
				if (map[0][i] == '.') break;

			if (!map[0][i])
			{
				if (ghosts < 19) ghosts++;
				level++;
				init();
			}
		}

		printf("Do you want to play again [y/n]? ");
		ch = getchar();
		if ((ch == 'y') || (ch == 'Y'))
			play = 1;
	}
	
	printf("\n");
	reset_keypress();
	
	return 0;
}

void set_keypress()
{
	/* declare variables used */
	struct termios new_settings;
	int opts;
	
	/* set a few options for the console input */
	tcgetattr(0,&stored_settings);
	new_settings = stored_settings;
	new_settings.c_lflag &= (~ICANON);
	new_settings.c_lflag &= (~ECHO);
	new_settings.c_cc[VTIME] = 0;
	new_settings.c_cc[VMIN] = 1;
	
	/* commit settings */
	tcsetattr(0,TCSANOW,&new_settings);

	return;
}

void reset_keypress()
{
	/* restore original console input settings */
	tcsetattr(0,TCSANOW,&stored_settings);

	return;
}

void init()
{
	int i;

	supermode = 0;

	for (i = 0; i < ghosts; i++)
	{
		ghouls[i].x = 10;
		ghouls[i].y = 4;
		ghouls[i].eaten = 0;
	}

	/* We're going to cheat -- ghouls[0] is us :) */
	ghouls[0].y = 8;

	strcpy(map[0], "********************\n");
	strcpy(map[1], "*+................+*\n");
	strcpy(map[2], "*..***.........***.*\n");
	strcpy(map[3], "*......**...**.....*\n");
	strcpy(map[4], "*..**..*     *..**.*\n");
	strcpy(map[5], "*......*******.....*\n");
	strcpy(map[6], "****............****\n");
	strcpy(map[7], "**...****..****...**\n");
	strcpy(map[8], "*+................+*\n");
	strcpy(map[9], "********************\n");
}

void next()
{
	int ch, i, pos, us, direction;
	char tmp[210]; /* 21 columns * 10 rows */

	if (FD_ISSET(0, &rd))
	{
		ch = getchar();
		if (ch == 27)
		{
			ch = getchar();
			if (ch == 91)
			{
				ch = getchar();

				/* Right arrow key */
				if (ch == 67)
				{
					if (map[ghouls[0].y][ghouls[0].x+1] != '*')
						ghouls[0].x++;
				}
				/* left arrow key */
				else if (ch == 68)
				{
					if (map[ghouls[0].y][ghouls[0].x-1] != '*')
						ghouls[0].x--;
				}
				/* up arrow */
				else if (ch == 65)
				{
					if (map[ghouls[0].y-1][ghouls[0].x] != '*')
						ghouls[0].y--;
				}
				/* down arrow */
				else if (ch == 66)
				{
					if (map[ghouls[0].y+1][ghouls[0].x] != '*')
						ghouls[0].y++;
				}
			}
		}
	}

	for (i = 1; i < ghosts; i++)
	{
		direction = (int)(4.0 * rand() / (RAND_MAX + 1.0));
		if (direction == 0)
		{
			if (map[ghouls[i].y][ghouls[i].x+1] != '*')
				ghouls[i].x++;
		}
		else if (direction == 2)
		{
			if (map[ghouls[i].y][ghouls[i].x-1] != '*')
				ghouls[i].x--;
		}
		else if (direction == 1)
		{
			if (map[ghouls[i].y-1][ghouls[i].x] != '*')
				ghouls[i].y--;
		}
		else if (direction == 3)
		{
			if (map[ghouls[i].y+1][ghouls[i].x] != '*')
				ghouls[i].y++;
		}
	}

	if (supermode) supermode--;

	strcpy(tmp, map[0]);
	
	us = ghouls[0].x + (ghouls[0].y * 21);
	if (tmp[us] == '.')
	{
		map[ghouls[0].y][ghouls[0].x] = ' ';
		points++;
	}
	else if (tmp[us] == '+')
	{
		map[ghouls[0].y][ghouls[0].x] = ' ';
		supermode += 25;
	}
	
	for (i = 1; i < ghosts; i++)
	{
		pos = ghouls[i].x + (ghouls[i].y * 21);
		if (pos == us)
		{
			if (!supermode)
				ghouls[0].eaten = 1;
			else
				ghouls[i].eaten = 1;
		}

		/* home turf */
		if ((ghouls[i].y == 4) && (ghouls[i].x > 7) && (ghouls[i].x < 13))
			ghouls[i].eaten = 0;
		
		if (ghouls[i].eaten)
			tmp[pos] = '-';
		else
			tmp[pos] = '~';
	}

	if (!ghouls[0].eaten) tmp[us] = 'c';
	
	printf("\n\n%slevel: %i, score: %i", tmp, level, points);
	if (supermode) printf(", super: %i", supermode);
	printf("\n");

	return;
}

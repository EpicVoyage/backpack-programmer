#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

int main(int argc, char** argv)
{
	int e;

	if (argc != 3) {
		printf("Usage:\n%s source dest\n", argv[0]);
		exit(0);
	}
	
	e = rename(argv[1], argv[2]);
	
	if (e == -1) {
		e = errno;
		perror("rename");
	} else {
		e = 0;
	}

	return e;
}


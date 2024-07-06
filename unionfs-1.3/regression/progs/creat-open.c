#include <unistd.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <errno.h>

int main(int argc, char *argv[])
{
	return (creat(argv[0], 0755) == -1 ? errno : 0);
}

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void usage(const char *pname);

int main(int argc, char **argv)
{
	if (argc != 2) {
		usage(argv[0]);
	}

	double n;

	if (sscanf(argv[1], "%lf", &n)) {
		printf("%lf\n", log2(n));
	} else {
		usage(argv[0]);
	}

	return 0;
}

void usage(const char *pname)
{
	fprintf(stderr, "Usage: %s number\n", pname);
	exit(EXIT_FAILURE);
}

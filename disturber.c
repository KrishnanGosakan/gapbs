#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void alloc_and_wait(size_t size) {
	char *mem = (char *)malloc(size);
	//memset(mem, size, 'a');
	sleep(240);
}

int main() {
	size_t sz = 64*1024*1024*1024ULL;
	alloc_and_wait(sz);
	return 0;
}

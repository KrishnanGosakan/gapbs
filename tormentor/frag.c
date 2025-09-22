#include <stdio.h>

#include <sys/mman.h>

#include <string.h>
#include <unistd.h>
#include <stdlib.h>

void *alloc(size_t size)
{      
        char *mem;
	mem = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	madvise(mem, size, MADV_NOHUGEPAGE);
        memset(mem, 'a', size);
        return (void *)mem;
}

void dealloc(void *addr, size_t free_size)
{
	munmap(addr, free_size);
}

int main(int a, char *b[])
{
        size_t alloc_size = 2*1024*1024; //2M one huge page
	size_t free_size = 2*512*1024; //free 75% of each huge page
	size_t slack_size = 15*1024*1024; //slack of 15G

        long pages = sysconf(_SC_PHYS_PAGES);
	int page_size_kb = sysconf(_SC_PAGE_SIZE)/1024;
	long allocs_slack = (pages*page_size_kb) - slack_size; //leave slack mem
	long num_allocs = allocs_slack/(2*1024);

        char *allocs[num_allocs];

        for (int i = 0; i < num_allocs; i++)
        {
                allocs[i] = (char *)alloc(alloc_size);
        }
        printf("done allocation of %lu GB\n",alloc_size*num_allocs/(1024*1024*1024));


	for (int i = 0; i < num_allocs; i++)
	{
		dealloc(allocs[i], free_size);
	}
	printf("deallocated memory\n");

	sleep(10000);
        return 0;
} 


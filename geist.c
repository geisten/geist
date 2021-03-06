#include <stdio.h>
#include <unistd.h>
#include <libgen.h>
#include <stdlib.h>

int main(int argc, char* argv[argc]){
    int c;

    while((c=getopt(argc, argv, "h")) != -1){
        switch(c){
            case 'h': fprintf(stderr, "usage: %s [-h]\n", basename(argv[0]));
                      exit(EXIT_FAILURE);
                      break;
        }
    }

    while((c = getchar())!=EOF){
        putchar(c);
    }

}

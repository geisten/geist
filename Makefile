SRC = geist.c
OBJ=$(SRC:.c=.o)
DEPS= $(OBJ:.o=.d)
CC=x86_64-elf-gcc
OBJCOPY=x86_64-elf-objcopy

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
#  -Wextra enables some extra warning flags that are not enabled by -Wall. 
#  -Wpedantic issue all the warnings demanded by strict ISO C
#  -Wunused-const-variable warn whenever a constant static variable is unused aside from its declaration.
#  -Wwrite-strings copying the address of one into a non-const char * pointer produces a warning. 
#  -Wconversion warn for implicit conversions that may alter a value.
CFLAGS = -Wall -Wextra -Wpedantic -Wunused-const-variable -Wwrite-strings -Wconversion

geist: $(SRC)
	$(CC) -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
  -fno-omit-frame-pointer -pg -mnop-mcount \
  -o $@.com.dbg $^ -fuse-ld=bfd -Wl,-T,cosmo/ape.lds \
  -include  cosmo/cosmopolitan.h cosmo/crt.o cosmo/ape.o cosmo/cosmopolitan.a
	$(OBJCOPY) -S -O binary $@.com.dbg $@.com

all: geist

debug: CFLAGS+= -DDEBUG -fsanitize=address -O1 -fno-omit-frame-pointer -g
debug: geist


.PHONY:clean
clean:
	rm -f $(OBJ) $(DEPS) geist geist.com.dbg geist.com

-include $(DEPS)

test-help: test/test_help.txt
	@./geist -h 2>&1 | diff -u $^ - ||  (echo "Test $^ failed" && exit 1)

test-neg-data: test/test_input_out.data test/test_input_neg_in.data
	@! ./geist < test/test_input_neg_in.data | diff -u test/test_input_out.data - &>/dev/null ||  (echo "Test $^ failed" && exit 1)

test-data: test/test_input_out.data test/test_input_in.data
	@ ./geist < test/test_input_in.data | diff -u test/test_input_out.data - ||  (echo "Test $^ failed" && exit 1)

test: test-help test-neg-data test-data
	@echo "Success, all tests passed."

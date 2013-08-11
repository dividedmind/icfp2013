CFLAGS += -std=gnu99 -W -Wall -g -O3 -march=native
CFLAGS += $(shell pkg-config --cflags json libcurl)
LDFLAGS += $(shell pkg-config --libs json libcurl)

solve: solve.o eval.o print.o webapi.o gen.o
	gcc $^ $(LDFLAGS) -o $@

.PHONY: clean

clean:
	rm -f *.o
	rm -f solve

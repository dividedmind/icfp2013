CFLAGS += -std=gnu99 -W -Wall -O3 -fopenmp
CFLAGS += $(shell pkg-config --cflags json libcurl)
LDFLAGS += $(shell pkg-config --libs json libcurl) -fopenmp -lm

solve: solve.o eval.o print.o webapi.o gen.o gene.o
	gcc $^ $(LDFLAGS) -o $@

.PHONY: clean

clean:
	rm -f *.o
	rm -f solve

CFLAGS += -std=c99 -W -Wall

solve: main.o eval.o print.o

.PHONY: clean

clean:
	rm -f *.o
	rm -f solve

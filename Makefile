all:
        @nasm -f elf32 strlen.s -o strlen.o
clean:
        rm strlen.o
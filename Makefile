all:
        @nasm -f elf32 strlen.s -o strlen.o
        @nasm -f elf32 is_alpha.s -o is_alpha.o
        @nasm -f elf32 is_num.s -o is_num.o
clean:
        rm strlen.o is_alpha.o is_num.o
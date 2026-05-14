all:
        @nasm -f elf32 strlen.s -o strlen.o
        @nasm -f elf32 is_alpha.s -o is_alpha.o
        @nasm -f elf32 is_num.s -o is_num.o
        @nasm -f elf32 is_alnum.s -o is_alnum.o
        @nasm -f elf32 print_capital.s -o print_capital.o
clean:
        rm strlen.o is_alpha.o is_num.o is_alnum.o print_capital.o
all:
        @nasm -f elf32 strlen.s -o strlen.o
        @nasm -f elf32 is_alpha.s -o is_alpha.o
        @nasm -f elf32 is_num.s -o is_num.o
        @nasm -f elf32 is_alnum.s -o is_alnum.o
        @nasm -f elf32 print_capital.s -o print_capital.o
        @nasm -f elf32 string_compare.s -o string_compare.o
        @nasm -f elf32 print_num.s -o print_num.o
        @nasm -f elf32 ascii_to_int.s -o ascii_to_int.o
        @nasm -f elf32 print_unsigned_num.s -o print_unsigned_num.o
clean:
        rm strlen.o is_alpha.o is_num.o is_alnum.o print_capital.o string_compare.o \
        print_num.o ascii_to_int.o print_unsigned_num.o
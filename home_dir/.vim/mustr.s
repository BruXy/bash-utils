/*
 Gnu Assembler 
 http://sourceware.org/binutils/docs-2.17/as/index.html
 as -gstabs+ -o output vstup.s
*/

.section .data  # datova sekce -- deklarace inicializovanych promennych
	value: .int
	value2: .float
	value3: .double
	text:   .ascii "Ahoj!\n"
	text2:  .asciz

.section .bss  # deklarace neinicializovanych promennych
	.lcomm buffer 12

.section .text

.globl _start
_start:

# pri sestaveni gcc je pocatecni symbol main
# globl main 
# main:
	



	movl $1, %eax # syscall exit
	movl $0, %ebx
	int $0x80


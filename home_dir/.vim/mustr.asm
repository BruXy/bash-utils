; Dokumentace: http://alien.dowling.edu/~rohit/nasmdoc0.html
; nasm -g -f elf source.asm 
; (-g ... debug info)
; ld -s -o output source.o

SECTION .data	;sekce s ulozenymi daty
	pozdrav db "Hello, world!", 0xa	;øetìzec + konec øádku (LF)
	len equ $-pozdrav	;pøiøazení délky øetìzce symbolu

	; BSS ... Block Started by a Symbol
SECTION .bss    ; sekce s vyhrazenyn prostorem pro neinicializovane promenne

SECTION .text	;zacatek sekce s kodem programu

global _start	;definice globálního symbolu pro linker

_start:

	mov eax, 1	; syscall exit
	mov ebx, 0	
	int 0x80 




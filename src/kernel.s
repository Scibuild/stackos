
; calling convention: 
; parameters: ax dx cx bx (if any are used as low, ah dh ch bh)
; return: si, di (either pointer or value)

jmp stackos_kernel_start

stackos_kernel_start:
; set video mode to 0x07
; http://minuszerodegrees.net/video/bios_video_modes.htm
;	mov ax, 0x07
;	int 0x10

	call stackos_clear_screen
	mov ax, welcome_msg
	call stackos_print_string

.shell_loop:
	mov ax, prompt_char
	call stackos_print_char
	mov di, linebuffer

.key_loop:
	call stackos_get_keystroke

	mov ax, si
	cmp ax, newline_char 
	je .if_enter_key
	cmp ax, backspace_char 
	je .if_backspace_key
	cmp di, linebuffer_end
	je .key_loop

	call stackos_print_char
	stosb

	jmp .key_loop


.if_enter_key:
	mov ax, carridge_return_char
	call stackos_print_char
	mov ax, newline_char
	call stackos_print_char


	mov ax, linebuffer

	call stackos_interpret_string

	mov dx, 0
	mov cx, linebuffer_len
	call stackos_memset

	jmp .shell_loop

.if_backspace_key:
	cmp di, linebuffer
	je .key_loop
	call stackos_print_char
	mov al, ' '
	call stackos_print_char
	mov al, backspace_char
	call stackos_print_char
	dec di
	mov byte [di], 0

	jmp .key_loop


welcome_msg db "Welcome to stackOS 0.0.0", 10, 13, 0

prompt_char equ '>'

newline_char equ 13
carridge_return_char equ 10
backspace_char equ 8

db 0xab, 0xcd
linebuffer_len equ 78
linebuffer times linebuffer_len db 0
linebuffer_end: db 0

%include "mem.s"
%include "bios.s"
%include "interpreter.s"

; vim:ft=nasm

; if it calls an interrupt, its in here


; IN al : character to print
stackos_print_char:
	push ax
	push bx
	mov ah, 0xe
	mov bh, 0
	int 0x10
	pop bx
	pop ax
	ret


; IN ax : string pointer null terminated
stackos_print_string:
	push ax
	push bx
	mov si, ax
	mov ah, 0xe
	mov bh, 0
.loop:
	lodsb ; al = *si++
	or al, al ; faster zero test
	jz .end
	int 0x10
	jmp .loop
.end:
	pop bx
	pop ax
	ret

; from mikeos
stackos_clear_screen:
	pusha

	mov ax, 0			; Position cursor at top-left
	call stackos_move_cursor

	mov ah, 6			; Scroll full-screen
	mov al, 0			; Normal white on black
	mov bh, 7			;
	mov cx, 0			; Top-left
	mov dh, 24			; Bottom-right
	mov dl, 79
	int 10h

	popa
	ret

; from mikeos
; IN al : column
; IN ah : row
stackos_move_cursor:
	pusha
	mov dx, ax

	mov bh, 0
	mov ah, 2
	int 10h				; BIOS interrupt to move cursor

	popa
	ret

; blocks until keystroke
; OUT si : ASCII character
stackos_get_keystroke:
	push ax
	mov ah, 0
	int 0x16
	xor ah, ah
	mov si, ax
	
	pop ax
	ret
; vim:ft=nasm

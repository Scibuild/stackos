

; IN ax: pointer to null terminated string
stackos_interpret_string:
	pusha

	mov dx, [program_stack_pointer]
	test dx, dx
	jne .postinit
	mov dx, program_stack
	mov [program_stack_pointer], dx

.postinit:

	call stackos_skip_space
	mov ax, si
	; we are using bx to store the string pointer while we arent using it
	mov bx, ax


	; check if null character (at end)
	mov si, ax
	mov al, [si]
	test al, al
	je .done
	; reload ax
	mov ax, bx

	; try to match word 'print'
	mov dx, stackos_s_print_word
	call stackos_match_string
	jc .print_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_add_word
	call stackos_match_string
	jc .add_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_sub_word
	call stackos_match_string
	jc .sub_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_mul_word
	call stackos_match_string
	jc .mul_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_div_word
	call stackos_match_string
	jc .div_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_drop_word
	call stackos_match_string
	jc .drop_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_dup_word
	call stackos_match_string
	jc .dup_word
	; reload ax if failed to match
	mov ax, bx
	
	mov dx, stackos_s_swap_word
	call stackos_match_string
	jc .swap_word
	; reload ax if failed to match
	mov ax, bx

	mov dx, stackos_s_over_word
	call stackos_match_string
	jc .over_word
	; reload ax if failed to match
	mov ax, bx


	mov dx, stackos_s_rot_word
	call stackos_match_string
	jc .rot_word
	; reload ax if failed to match
	mov ax, bx

	; otherwise, check if digit is a number
	mov si, ax
	mov ax, [si]
	call stackos_is_digit
	mov ax, si
	jc .number
	; reload ax if failed to match
	mov ax, bx

.word_not_found:
	mov ax, stackos_s_unrecognised_word_message
	call stackos_print_string
	mov ax, si
	; if there was an unrecognised word, bail out
	jmp .done

.print_word:
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov ax, si
	call stackos_print_word_decimal
 	mov ax, stackos_s_newline
 	call stackos_print_string

	; mov ax, stackos_s_print_message
	; call stackos_print_string
	mov ax, bx
	jmp .postinit

.add_word:
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov cx, si
	call pop_from_stack
	mov ax, si
	add ax, cx
	call push_to_stack

	mov ax, bx
	jmp .postinit
.sub_word:
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov cx, si
	call pop_from_stack
	mov ax, si
	sub ax, cx
	call push_to_stack

	mov ax, bx
	jmp .postinit
.mul_word:
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov cx, si
	call pop_from_stack
	mov ax, si
	xor dx, dx
	mul cx
	call push_to_stack

	mov ax, bx
	jmp .postinit
.div_word:
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov cx, si
	call pop_from_stack
	mov ax, si
	xor dx, dx
	div cx
	call push_to_stack

	mov ax, bx
	jmp .postinit

.drop_word: ; a --
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack

	mov ax, bx
	jmp .postinit

.dup_word: ; a -- a a
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov ax, si
	call push_to_stack
	call push_to_stack

	mov ax, bx
	jmp .postinit

.swap_word: ; a b -- b a
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov ax, si
	call pop_from_stack
	mov cx, si
	call push_to_stack
	mov ax, cx
	call push_to_stack

	mov ax, bx
	jmp .postinit
.over_word: ; a b -- a b a
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov dx, si
	call pop_from_stack
	mov ax, si

	call push_to_stack
	xchg ax, dx
	call push_to_stack
	mov ax, dx
	call push_to_stack


	mov ax, bx
	jmp .postinit

.rot_word:  ; a b c -- b c a
	; save the parsed state, do this every matched word 
	mov bx, si
	call pop_from_stack
	mov cx, si
	call pop_from_stack
	mov ax, si
	call pop_from_stack
	mov dx, si

	call push_to_stack
	mov ax, cx
	call push_to_stack
	mov ax, dx
	call push_to_stack


	mov ax, bx
	jmp .postinit

.number:
 	call stackos_parse_word_decimal
	mov bx, si
	mov ax, di
	call push_to_stack

; 	call stackos_print_word_decimal
; 	mov ax, stackos_s_newline
; 	call stackos_print_string

	mov ax, bx
	jmp .postinit

.done:
	popa
	ret


; IN ax : value to be pushed
push_to_stack: 
	push di
	mov di, [program_stack_pointer]
	mov [di], ax
	lea di, [di + 2]
	mov [program_stack_pointer], di
	pop di
	ret

; OUT si : value read from stack
pop_from_stack: 
	push di
	mov si, [program_stack_pointer]
	cmp si, program_stack
	je .error
	lea si, [si - 2]
	mov di, [si]
	mov [program_stack_pointer], si
	mov si, di
	pop di
	ret

.error
	push ax
	mov ax, stackos_s_pop_error
	call stackos_print_string
	pop ax
	pop di
	ret




stackos_s_print_word db "print", 0
stackos_s_add_word db "+", 0
stackos_s_sub_word db "-", 0
stackos_s_mul_word db "*", 0
stackos_s_div_word db "div", 0

stackos_s_drop_word db "drop", 0 
stackos_s_dup_word db "dup", 0
stackos_s_swap_word db "swap", 0
stackos_s_over_word db "over", 0
stackos_s_rot_word db "rot", 0

stackos_s_pop_error db "Pop error: stack empty", 13, 10, 0
stackos_s_unrecognised_word_message db "Unrecognised word", 13, 10, 0
stackos_s_newline db 13, 10, 0

; IN al : byte to print

stackos_print_byte_hex:
; we store the temporary number in bx while formatting in ax
	pusha

	mov bl, al
	mov cx, '0' ; ascii 0
	mov dx, 'a'-10 ; ascii a minus 10
	; move top nybble to bottom
	shr al, 4
	; check if abc.. or 012..
	cmp al, 0xa
	cmovge cx, dx
	; select the correct offset into cx cmovg cx, dx
	add al, cl
	call stackos_print_char

	; repeat but this time...
	mov al, bl
	mov cx, '0' ; ascii 0
	; mov dx, 'a'-10 ; ascii a minus 10
	; ... only the lower digits
	and al, 0xf
	cmp al, 0xa
	; select the correct offset into cx
	cmovge cx, dx
	add al, cl
	call stackos_print_char

	popa
	ret



; IN ax: word to print
stackos_print_word_decimal:
	pusha

	pusha
	mov ax, decimal_buffer
	mov dl, 0
	mov cx, 7
	call stackos_memset
	popa

	mov bx, ax
	mov di, decimal_buffer_end
	std ; set direction backwards
	mov cx, 10 ; stays as ten because we can only divide by register
.loop:
	cmp di, decimal_buffer
	jl .done



	xor dx, dx
	div cx ; remainder in dx
	mov al, dl 
	add al, '0'
	; push into string buffer
	stosb

	mov ax, bx
	xor dx, dx ; div divides into dx:ax
	div cx
	mov bx, ax

	test ax, ax ; cmp ax, 0
	jne .loop

.done:
	cld ; revert to direction forwards	
	inc di
	mov ax, di
	call stackos_print_string

	popa
	ret

dw 0xabcd
decimal_buffer times 5 db 0 ; max length is -32767, but for now only unsigned so 65535, plus null byte
decimal_buffer_end db 0
decimal_buffer_terminator db 0


; IN al: ascii code to check
; OUT clear flag is set if digit
stackos_is_digit:
	cmp al, 0x30
	jl .not_digit
	cmp al, 0x39
	jg .not_digit
	stc
	ret
	
.not_digit:
	clc
	ret


; assumes at least one character is a digit
; IN ax: start of string
; OUT si: pointer past end of parsed string
; OUT di: parsed value
stackos_parse_word_decimal:
	push ax
	push bx
	push cx
	pushf
	; ax -> si, ax = 0; while [si] is a digit, load into dl, subtract ascii offset, multiply ax by 10 and add dl

	mov si, ax
	; ax stores the result
	xor ax, ax
	; bl stores the character
	xor bx, bx

	; use the direction flag to store negative numbers
	; this is assumed and might be unnecessary TODO
	cld

	mov bl, [si]
	cmp bl, '-'
	jne .post_load
	std
	inc si


.loop:
	; bl stores the read byte
	mov bl, [si]
.post_load:
	cmp bl, '0'
	jl .done
	cmp bl, '9'
	jg .done
	inc si
	sub bl, '0'
	mov cx, 10
	mul cx
	add ax, bx
	jmp .loop

.done:
	mov di, ax
	
	popf
	pop cx
	pop bx
	pop ax
	ret

; IN ax: string to match (null terminated)
; IN dx: string to match in
; OUT si: pointer past end of matched string
; OUT carry flag set if matched, not set if not matched
stackos_match_string:
	push cx
	mov si, ax
	mov di, dx

.loop:
	mov cl, [si]
	mov ch, [di]
	test ch, ch ; test if ch is zero
	jz .endofdx
	inc si
	inc di
	cmp cl, ch
	je .loop

	
.not_matched:
	clc
	pop cx
	ret

.endofdx:
	test cl, cl
	je .matched
	cmp cl, ' '
	jne .not_matched

.matched:
	stc
	pop cx
	ret

; IN ax: start address
; OUT si: end address
stackos_skip_space:
	push ax
	mov si, ax
.loop:
	mov al, [si]
	cmp al, ' '
	jne .done
	inc si
	jmp .loop


.done:
	pop ax
	ret


program_stack_size equ 256
program_stack_pointer dw 0
program_stack times 256 dw 0

; vim:ft=nasm

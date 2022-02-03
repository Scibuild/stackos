
; IN ax: address
;    dl: value
;    cx: length
stackos_memset:
	pusha
	mov di, ax
	mov al, dl
.loop:
	stosb
	dec cx
	cmp cx, 0
	jne .loop

	popa
	ret

; vim:ft=nasm

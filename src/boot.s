[ORG 0x7c00]

; https://github.com/pablojimenezmateo/curriculum-bootloader/blob/master/boot.asm
bits 16

boot:

    ; This is a BPB, so that the BIOS does not overwrite our code
    ; https://stackoverflow.com/questions/47277702/custom-bootloader-booted-via-usb-drive-produces-incorrect-output-on-some-compute
    jmp stackos_start
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

    ; Dos 4.0 EBPB 1.44MB floppy
    OEMname:           db    "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw    512
    sectPerCluster:    db    1
    reservedSectors:   dw    1
    numFAT:            db    2
    numRootDirEntries: dw    224
    numSectors:        dw    2880
    mediaType:         db    0xf0
    numFATsectors:     dw    9
    sectorsPerTrack:   dw    18
    numHeads:          dw    2
    numHiddenSectors:  dd    0
    numSectorsHuge:    dd    0
    driveNum:          db    0
    reserved:          db    0
    signature:         db    0x29
    volumeID:          dd    0x2d7e5a1a
    volumeLabel:       db    "NO NAME    "
    fileSysType:       db    "FAT12   "

    ; This is used to offset all memory addresses by 8 bytes, or the size of the PDF magic numbers
    dw 0xffff, 0xffff, 0xffff, 0xffff



; jmp stackos_start

stackos_start:
	mov [bootdrv], dl
	xor ax, ax
  ; set the start of the boot sector code to 0x7c00 for interrupts (data segment)
	; mov ax, 0x07c0
	mov ds, ax
	mov es, ax


	; mov ax, 0x07c0
	; add ax, 288    ; 4k after the end of the boot loader
	cli
	mov ss, ax
	mov sp, 0x7c00
	sti


	; clear the direction flag
	cld

	mov si, msg
	call stackos_bios_puts

; 	mov ah, 8
; 	int 0x13
; 	and cx, 0x3f
; 	mov al, dl
; 	call stackos_bios_print_byte
; 	mov al, dh
; 	call stackos_bios_print_byte
	
	mov si, 2

.top:
	mov ah, 2  ; reading from floppy sub interrupt number
	mov al, 4  ; read in 4 sectors
	mov ch, 0  ; first cylinder
	mov cl, 2  ; sector to read (first sector is boot loader)
	xor dh, dh ; head 0
	mov dl, [bootdrv]

; 	xor bx, bx  ; no offset
; 	mov es, bx
; 	mov bx, 0x7e00 ; we load the kernel at 0x7e00, just after the boot loader

	mov bx, 0x1000
	mov es, bx
	xor bx, bx
	int 0x13
	; carry is set if there is an error
	jnc .success
	dec si
	jz .drive_load_error
	xor ah, ah
	int 0x13
	jmp .top


.success:

	mov si, success_msg
	call stackos_bios_puts
	; mov ax, 0x07e0
	mov ax, 0x1000
	mov ds, ax
	mov es, ax
	jmp 0x1000:0x0000

.drive_load_error:
	mov si, stackos_read_kernel_fail_msg 
	call stackos_bios_puts
	jmp $



; char in al
stackos_bios_putc:
	push ax
	push bx
	mov ah, 0xe
	mov bh, 0
	int 0x10
	pop bx
	pop ax
	ret



; string pointer in si
stackos_bios_puts:
	push ax
	push bx
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





msg db "Hello world!", 13, 10, 0
success_msg db "Successfully loaded kernel!", 13, 10, 0

stackos_read_kernel_fail_msg db "Could not load kernel from disk.", 13, 10, 0

bootdrv db 0

times 510-($-$$) db 0
dw 0xaa55

; vim:ft=nasm

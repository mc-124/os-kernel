%include "src/boot/inc.s"
[bits 16]
org LOADER_ADDR
jmp loader_start

GDT_BASE:
    dd 0x00000000
    dd 0x00000000

CODE_DESC:
    dd 0x0000ffff
    dd DESC_CODE_H4

DATA_STACK_DESC:
    dd 0x0000ffff
    dd DESC_DATA_H4

VIDEO_DESC:
    dd 0x80000007
    dd DESC_VIDEO_H4

GDT_SIZE equ $-GDT_BASE
GDT_LIMIT equ GDT_SIZE-1
times 60 dq 0

SELECTOR_CODE  equ (1<<3)+TI_GDT+RPL0
SELECTOR_DATA  equ (2<<3)+TI_GDT+RPL0
SELECTOR_VIDEO equ (3<<3)+TI_GDT+RPL0

gdt_ptr dw GDT_LIMIT

loader_start:
    mov ax,GRAM_ADDR
    mov gs,ax

    ; print chars
    mov byte[gs:0x00],'B'
    mov byte[gs:0x02],'o'
    mov byte[gs:0x04],'o'
    mov byte[gs:0x06],'t' 
    mov byte[gs:0x08],' '
    mov byte[gs:0x0a],'L'
    mov byte[gs:0x0c],'o'
    mov byte[gs:0x0e],'a'
    mov byte[gs:0x10],'d'
    mov byte[gs:0x12],'e'
    mov byte[gs:0x14],'r'

    ; A20
    in al,0x92
    or al,0b00000010
    out 0x92,al

    ; load gdt
    lgdt [gdt_ptr]

    mov eax,cr0
    or eax,0x1
    mov cr0,eax

    jmp dword SELECTOR_CODE:p_mode_start

[bits 32]
; 保护模式启动
p_mode_start:
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,LOADER	
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    mov byte[gs:160],'p'

; stop
jmp $
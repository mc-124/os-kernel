%include "src/boot/inc.s"
[bits 16]
org LOADER_ADDR

mov ax,GRAM_ADDR
mov gs,ax

; print
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

jmp $
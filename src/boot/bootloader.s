%include "src/boot/inc.s"
org LOADER_ADDR

COLOR equ 0xa4

; print
mov byte[gs:0x00],'B'
mov byte[gs:0x01],COLOR
mov byte[gs:0x02],'o'
mov byte[gs:0x03],COLOR
mov byte[gs:0x04],'o'
mov byte[gs:0x05],COLOR
mov byte[gs:0x06],'t'
mov byte[gs:0x07],COLOR
mov byte[gs:0x08],' '
mov byte[gs:0x09],COLOR
mov byte[gs:0x0a],'L'
mov byte[gs:0x0b],COLOR
mov byte[gs:0x0c],'o'
mov byte[gs:0x0d],COLOR
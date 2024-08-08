org 0x7c00 ; MBR起始地址

; init
mov ax,cs
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00
mov ax,0xb800 ; 显存地址
mov gs,ax

; 清屏
mov ax,0x600
mov bx,0x700
mov cx,0        ; 0,0
mov dx,0x184f   ; 80,25
int 0x10

; 用显存操作屏幕
mov byte [gs:0x0],'M'
mov byte [gs:0x1],0xa4 ; a:背景绿色闪烁 4:前景红色
mov byte [gs:0x2],'B'
mov byte [gs:0x3],0xa4
mov byte [gs:0x4],'R'
mov byte [gs:0x5],0xa4
mov byte [gs:0x6],' '
mov byte [gs:0x7],0xa4
mov byte [gs:0x8],'t'
mov byte [gs:0x9],0xa4
mov byte [gs:0xa],'e'
mov byte [gs:0xb],0xa4
mov byte [gs:0xc],'s'
mov byte [gs:0xd],0xa4
mov byte [gs:0xe],'t'
mov byte [gs:0xf],0xa4

jmp $

times 510-($-$$) db 0
db 0x55,0xaa ; MBR Magic Number
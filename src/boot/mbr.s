%include "src/boot/inc.s"
[bits 16]
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
mov cx,0        ; (0, 0)
mov dx,0x184f   ; (80, 25)
int 0x10

;000 MBR
;0a0 Read Disk
;140 Ready
;1e0 Read
;280 Init Loader

; 用显存操作屏幕
; 000 0a0 140 1e0 280 320 3c0 460 500 5a0 
; 640 6e0 780 820 8c0 960 a00 b40 be0 c80 
; d20 dc0 e60 f00
; \n: +0xa
mov byte[gs:0x0],'M'
mov byte[gs:0x2],'B'
mov byte[gs:0x4],'R'

mov eax,LOADER_START    ; 起始扇区LBA地址
mov bx,LOADER_ADDR      ; 写入地址
mov cx,1                ; 待写入扇区数

mov byte[gs:0xa0],'R'
mov byte[gs:0xa2],'e'
mov byte[gs:0xa4],'a'
mov byte[gs:0xa6],'d'
mov byte[gs:0xa8],' '
mov byte[gs:0xaa],'D'
mov byte[gs:0xac],'i'
mov byte[gs:0xae],'s'
mov byte[gs:0xb0],'k'

call read_disk          ; 读取起始部分

mov byte[gs:0x320],'I'
mov byte[gs:0x322],'n'
mov byte[gs:0x324],'i'
mov byte[gs:0x326],'t'
mov byte[gs:0x328],' '
mov byte[gs:0x32a],'L'
mov byte[gs:0x32c],'o'
mov byte[gs:0x32e],'a'
mov byte[gs:0x330],'d'
mov byte[gs:0x332],'e'
mov byte[gs:0x334],'r'

jmp LOADER_ADDR         ; 前往loader

; 读取磁盘n个扇区
read_disk:
    mov esi,eax ; 备份eax
    mov di,cx   ; 备份cx

    ; 设置要读取的删去数
    mov dx,0x1f2
    mov al,cl
    out dx,al ; 读取的扇区数

    mov eax,esi
    
    ; LBA地址7-0写入0x1f3
    mov dx,0x1f3
    out dx,al

    ; LBA地址15-8写入0x1f4
    mov cl,8
    shr eax,cl
    mov dx,0x1f4
    out dx,al

    ; LBAA地址23-169写入0x1f5
    shr eax,cl
    mov dx,0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f 
    or al,0xe0
    mov dx,0x1f6
    out dx,al

    ; 向0x1f7写入命令 0x20
    mov dx,0x1f7
    mov al,0x20
    out dx,al

; 检测硬盘状态
.not_ready:
    ;mov byte[gs:0xa4],'N'
    ;mov byte[gs:0xa6],'R'
    ; 写时表示写入命令字 读时表示读入硬盘状态
    nop
    in al,dx
    and al,0x88 ; 第4位为1表示硬盘控制器已准备好数据传输 第7位为1表示硬盘忙
    cmp al,0x08 
    jnz .not_ready ; 未准备好 继续等待

    mov byte[gs:0x140],'R'
    mov byte[gs:0x142],'e'
    mov byte[gs:0x144],'a'
    mov byte[gs:0x146],'d'
    mov byte[gs:0x148],'y'

    ; 从0x1f0读数据
    mov ax,di ; di为要读取的删去数 每个扇区512字节 每读入1b需要di*512/2次 所以di*256
    mov dx,256
    mul dx
    mov cx,ax

    mov dx,0x1f0

.read:
    in ax,dx
    mov [bx],ax
    add bx,2
    mov byte[gs:0x1e0],'R'
    mov byte[gs:0x1e2],'e'
    mov byte[gs:0x1e4],'a'
    mov byte[gs:0x1e6],'d'
    loop .read
    mov byte[gs:0x280],'R'
    mov byte[gs:0x282],'e'
    mov byte[gs:0x284],'a'
    mov byte[gs:0x286],'d'
    mov byte[gs:0x288],' '
    mov byte[gs:0x28a],'O'
    mov byte[gs:0x28c],'K'
    ret

times 510-($-$$) db 0
db 0x55,0xaa ; MBR Magic Number

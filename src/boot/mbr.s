%include "src/boot/inc.s"
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

; 用显存操作屏幕
; \n: +0xa
mov byte[gs:0x0],'M'
mov byte[gs:0x1],0xa5 ; a:背景绿色闪烁 4:前景红色
mov byte[gs:0x2],'B'
mov byte[gs:0x3],0xa5
mov byte[gs:0x4],'R'
mov byte[gs:0x5],0xa5

;#region disk
mov eax,LOADER_START    ; 起始扇区LBA地址
mov bx,LOADER_ADDR      ; 写入地址
mov cx,1                ; 待写入扇区数
call read_disk          ; 读取起始部分
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

    ; LAB地址23-169写入0x1f5
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
    ; 写时表示写入命令字 读时表示读入硬盘状态
    nop
    in al,dx
    and al,0x88 ; 第4位为1表示硬盘控制器已准备好数据传输 第7位为1表示硬盘忙
    cmp al,0x08 
    jnz .not_ready ; 未准备好 继续等待

    ; 从0x1f0读数据
    mov ax,di ; di为要读取的删去数 每个扇区512字节 每读入1b需要di*512/2次 所以di*256
    mov dx,256
    mul dx
    mov cs,ax

    mov dx,0x1f0

  .read:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .read
    ret
;#endregion

jmp $ ; while(1){}

times 510-($-$$) db 0
db 0x55,0xaa ; MBR Magic Number
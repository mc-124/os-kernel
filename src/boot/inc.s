LOADER_ADDR equ 0x900 ; loader org地址
LOADER_START equ 0x2
GRAM_ADDR equ 0xb800 ; 显存地址（VGA文本模式）

; bootloader
LOADER_STACK_TOP equ LOADER_ADDR
DESC_G equ 0b100000000000000000000000
DESC_D equ 0b10000000000000000000000
DESC_L equ 0
DESC_AVL equ 0

DLIMIT_CODE2 equ 0b11110000000000000000
DLIMIT_DATA2 equ 0b11110000000000000000
DLIMIT_VIDEO2 equ 0

DESC_P    equ 0b1000000000000000
DESC_DPL0 equ 0b00_0000000000000
DESC_DPL1 equ 0b01_0000000000000
DESC_DPL2 equ 0b10_0000000000000
DESC_DPL3 equ 0b11_0000000000000
DESC_S_CODE equ 0b1_000000000000
DESC_S_DATA equ 0b1_000000000000
DESc_S_SYS  equ 0
DESC_TYPE_CODE equ 0b1000_00000000

DESC_TYPE_DATA equ 0b1000_00000000
DESC_CODE_H4 equ (0<<24)+DESC_G+DESC_D\
+DESC_L+DESC_AVL+DLIMIT_CODE2\
+DESC_P+DESC_DPL0+DESC_S_CODE\
+DESC_TYPE_CODE+0h

DESC_DATA_H4 equ (0<<24)+DESC_G+DESC_D\
+DESC_L+DESC_AVL+DLIMIT_DATA2\
+DESC_P+DESC_DPL0+DESC_S_DATA\
+DESC_TYPE_DATA+0h

DESC_VIDEO_H4 equ (0<<24)+DESC_G+DESC_D\
+DESC_L+DESC_AVL+DLIMIT_VIDEO2+DESC_P\
+DESC_DPL0+DESC_S_DATA+DESC_TYPE_DATA+0h

RPL0 equ 0b00
RPL1 equ 0b01
RPL2 equ 0b10
RPL3 equ 0b11
TI_GDT equ 0b000
TI_LDT equ 0b100

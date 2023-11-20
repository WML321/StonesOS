%include "pm.inc"
org 7c00h
;分一下几个部分
; 第一个部分，创建描述符，创建GDT的base和长度
; 初始化段，也就是将段基址写入段描述符内
; lgdt
jmp _main
[SECTION .gdt]
DESC_GDT: Descriptor 0, 0, 0
DESC_VIDEO: Descriptor 0xb8000, 0xFFFF, DA_DRW
;DESC_CODE: Descriptor 0, CODELEN-1, DA_C
DSEC_DATA: Descriptor 0, STRLEN-1, DA_DR

GDT_LEN EQU $-DESC_GDT
GDT_ptr dw GDT_LEN
        dd 0

;定义段选择子，其实也就是段描述符相对DESC_GDT的偏移
SelectorData EQU DSEC_DATA - DESC_GDT
;SelectorCode EQU DESC_CODE - DESC_GDT
SelectorVideo EQU DESC_VIDEO - DESC_GDT
_main:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    xor ax, ax
    mov ax, 0xb800
    mov es, ax
    xor ax, ax
    mov byte [es:0140h], 's'
    mov byte [es:0141h], 0xA4
    mov byte [es:0142h], 't'
    mov byte [es:0143h], 0xA4
    mov byte [es:0144h], 'a'
    mov byte [es:0145h], 0xA4
    mov byte [es:0146h], 'r'
    mov byte [es:0147h], 0xA4
    mov byte [es:0148h], 't'
    mov byte [es:0149h], 0xA4
    call INIT_DESC
    ; 初始化GDT
    xor eax, eax
    mov eax, ds
    shl eax, 4
    add eax, DESC_GDT
    mov [GDT_ptr+2], eax
    lgdt [GDT_ptr]
; mov byte [es:014ah], 'Q'
; mov byte [es:014bh], 0xA4
; mov byte [es:014ch], 'W'
; mov byte [es:014dh], 0xA4
; ; 进入保护模式之前，先在实模式下显示几个字符，看是否成功

; ; 准备进入保护模式，进入保护模式和cr0中的一个控制位有关系0就是实模式，1就是保护模式
; cli ; 关闭中断
; in al, 0x92 ; 0x92这个端口通常用于访问控制寄存器
; or al, 0000_0010B
; out 0x92, al

; mov eax, cr0
; or eax, 1
; mov cr0, eax ; 此时控制寄存器已经改变，已经是保护模式了

; ; 加载数据段选择子
; mov ax, SelectorData
; mov ds, ax
; ; 加载b800的段选择子到gs中
; mov ax, SelectorVideo
; mov gs, ax
; mov edi, 0
; mov esi, 0
; ; 循环次数
; mov ecx, STRING
; print_loop:
;         mov al, ds:[edi]
;         mov ah, 0xC
;         mov gs:[esi], ax ;显示
;         add esi, 2
;         inc edi
;         loop print_loop
; hlt
; jmp dword SelectorCode:0 
; 保护模式下的过程是这样的：通过选择子，获取GDT中对应的基址，然后基址在加上冒号:后边的偏移，就是物理地址
; 所以这个jmp实现的效果就是跳转到代码段执行

INIT_DESC:
        ; mov di, DESC_CODE
        ; xor eax, eax
        ; mov ax, cs
        ; shl eax, 4
        ; add eax, _main_print
        ; call near INIT_ADDR_TO_DESC

        mov di, DSEC_DATA
        xor eax, eax
        mov ax, cs
        shl eax, 4
        add eax, STRING
        call near INIT_ADDR_TO_DESC
        ret

INIT_ADDR_TO_DESC:
; 这部分是放入基地址
; 基地址在的字节是
        mov [di+2], ax
        shr eax, 16
        mov [di+4], al
        mov [di+7], ah
        ret

; [SECTION .s32]
; [BITS 32]
; _main_print:
;     xor ax, ax

        ;打印字符串
        ;准备现存
        ; mov ax, SelectorVideo
        ; mov gs, ax
        ; mov esi, 0xA0 ;这是屏幕上的位置，例如一行80个字节，那么这里就是第二行开头

        ; ;要打印的内容
        ; mov ax, SelectorData
        ; mov ds, ax
        ; mov edi, 0

        ; ; 循环次数
        ; mov ecx, STRING
        ; print_loop:
        ;         mov al, ds:[edi]
        ;         mov ah, 0xC
        ;         mov gs:[esi], ax ;显示
        ;         add esi, 2
        ;         inc edi
        ;         loop print_loop
; CODELEN EQU $-_main_print

STRING: db 'Hello World!'
STRLEN EQU $-STRING

times 510-($-$$) db 0
dw 0xAA55
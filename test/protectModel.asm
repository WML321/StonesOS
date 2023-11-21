org 7c00h

jmp _main


_main:
    mov ax, cs
    mov ds, ax
;    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    ; 写入GDT地址
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, DESC_GDT
    mov [gdt_base], eax

    mov dword [DSEC_DATA],0x8000ffff
    mov dword [DSEC_DATA+0x04], 0x0040920b


    lgdt [gdt_size]

    in al, 0x92 ; 0x92这个端口通常用于访问控制寄存器
    or al, 0000_0010B
    out 0x92, al
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax ; 此时控制寄存器已经改变，已经是保护模式了

    ; 加载数据段选择子
    mov ax, 00000000000_01_000B
    mov ds, ax
    mov byte [0x00],'P'
    mov byte [0x02],'r'
    mov byte [0x04],'o'
    mov byte [0x06],'t'
    mov byte [0x08],'e'
    mov byte [0x0a],'c'
    mov byte [0x0c],'t'
    mov byte [0x0e],' '
    mov byte [0x10],'m'
    mov byte [0x12],'o'
    mov byte [0x14],'d'
    mov byte [0x16],'e'
    mov byte [0x18],' '
    mov byte [0x1a],'O'
    mov byte [0x1c],'K'
    mov byte [0x1e],'.'
    hlt  

; 定义数据
gdt_size dw 15
gdt_base dd 0

[SECTION .gdt]
DESC_GDT: db 0,0,0,0,0,0,0,0
;DESC_VIDEO: Descriptor 0xb8000, 0xFFFF, DA_DRW
;DESC_CODE: Descriptor 0, CODELEN-1, DA_C
DSEC_DATA: db 0,0,0,0,0,0,0,0
times 510-($-$$) db 0
db 0x55,0xaa
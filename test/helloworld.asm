org 7c00h
jmp _start

_start:
    ; 将字符串的地址加载到寄存器ecx中
    xor ax, ax
    mov ax, 0xb800
    mov es, ax
    
    mov byte [es:00a0h], 'H'
    mov byte [es:00a1h], 0xA4
    mov byte [es:00a2h], 'e'
    mov byte [es:00a3h], 0xA4

times 510-($-$$) db 0
dw 0xAA55

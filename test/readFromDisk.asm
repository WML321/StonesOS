; 使用LBA方式读取硬盘数据
; 从硬盘中读数据需要用到dx, al 和立即数

; 设置扇区数，LBA28，表示一个扇区需要用28位来表示，而一个端口是8位
; 所以需要4个端口，从0x1f3到0x1f6，多出来的4的位有其他用户，当作一种标志
; 先设置读的扇区数量，相关端口是0x1f2
; 然后就是设置LBA号
; 设置起始LBA号存在DS:SI中

; 扇区数量
readFromDisk:
    push ax
    push bx
    push cx
    push dx

    mov dx, 0x1f2
    mov al, 1
    out dx, al

    ; 其实LBA号
    inc dx ; 自增1，就是0x1f3了
    mov eax, [si]
    out dx, al

    inc dx ; 0x1f4
    mov al, ah
    out dx, al

    shr eax, 16

    inc dx ; 0x1f5
    out dx, al

    inc dx ; 0x1f6
    mov al, 0xe0
    or al, ah
    out dx, al

    ; 发送读硬盘指令
    inc dx
    mov al, 0x20
    out dx, al

    ; 等待硬盘操作完成
    .waits
        in al, dx ; 读完成后，dx代表的端口中是有数据的，这个数据中有标志位
        and al, 0x88
        cmp al, 0x08
        jnz .waits

    ; 读数据
    ; 设置读取数量
    mov cx, 256
    mov dx, 0x1f0 ; 读和写每次都是两个字节
    .read
        in ax, dx
        mov [si], ax
        add si, 2
        loop .read
    pop dx
    pop cx
    pop bx
    pop ax
    ret

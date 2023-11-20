DA_DR		EQU	90h	; 存在的只读数据段类型值
DA_DRW		EQU	92h	; 存在的可读写数据段属性值
DA_DRWA		EQU	93h	; 存在的已访问可读写数据段类型值
DA_C		EQU	98h	; 存在的只执行代码段属性值
DA_CR		EQU	9Ah	; 存在的可执行可读代码段属性值
DA_CCO		EQU	9Ch	; 存在的只执行一致代码段属性值
DA_CCOR		EQU	9Eh	; 存在的可执行可读一致代码段属性值
DA_32       EQU 32h
; GDT描述符
; usage: Descriptor Base, Limit, Attr
;        Base:  dd 15~39 55~063; 3~5字节，8字节
;        Limit: dd (low 20 bits available) 0~15 47~55；
;        Attr:  dw (lower 4 bits of higher byte are always 0) 39~47 51~55
%macro Descriptor 3
    dw %2 & 0FFFFh ; 第一段段界限 %2的低16位，还剩下高4位没用
    dw %1 & 0FFFFh ; 第一段段基址的前两个字节，%1的低16位，还剩高16位没用
    db (%1 >> 16) & 0FFh; 第一段段基址的第三个字节  %1的中间8位，还剩8位没用
    db %3 & 0FFh ; %3的低8位，剩高4位没用
    db ((%2 >> 16) & 0F0h) | ((%3 >> 8) & 00Fh); 这部分是%2的余下4位和%3的余下4位
    db (%1 >> 24) & 0FFh
%endmacro
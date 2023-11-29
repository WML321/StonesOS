BOTPAK    EQU        0x00280000
DSKCAC    EQU        0x00100000
DSKCAC0    EQU        0x00008000


CYLS    EQU        0x0ff0 ; 它可能与磁盘驱动器或磁盘操作相关
LEDS    EQU        0x0ff1 ; 可能显示器的控制相关
VMODE    EQU        0x0ff2 ; 它可能与视频模式或显示模式相关
SCRNX    EQU        0x0ff4 ; 它可能与屏幕的宽度（像素数）相关
SCRNY    EQU        0x0ff6 ; 它可能与屏幕的高度（像素数）相关
VRAM    EQU        0x0ff8 ; 它可能与视频RAM（显存）相关

        ORG        0xc200 ; 为什么以c200做为起始位置，暂时没有发现其特殊的地方



        MOV        AL,0x13
        MOV        AH,0x00
        INT        0x10 ; 计算机将显示模式切换为 VGA 13h 图形模式 
        ; VGA 13h 是一种低分辨率的图形模式，分辨率为 320x200 像素，支持 256 种颜色。这种图形模式适用于简单的图形绘制和游戏开发等应用。
        MOV        BYTE [VMODE],8
        MOV        WORD [SCRNX],320
        MOV        WORD [SCRNY],200
        MOV        DWORD [VRAM],0x000a0000



        MOV        AH,0x02
        INT        0x16             ; keyboard BIOS
        MOV        [LEDS],AL






        MOV        AL,0xff
        OUT        0x21,AL
        NOP
        OUT        0xa1,AL

        CLI



        CALL    waitkbdout
        MOV        AL,0xd1
        OUT        0x64,AL
        CALL    waitkbdout
        MOV        AL,0xdf            ; enable A20
        OUT        0x60,AL
        CALL    waitkbdout

; 保护模式转换

[INSTRSET "i486p"]

        LGDT    [GDTR0]
        MOV        EAX,CR0
        AND        EAX,0x7fffffff
        OR        EAX,0x00000001
        MOV        CR0,EAX
        JMP        pipelineflush

        MOV        AX,1*8
        MOV        DS,AX
        MOV        ES,AX
        MOV        FS,AX
        MOV        GS,AX
        MOV        SS,AX



        MOV        ESI,bootpack    ; 源
        MOV        EDI,BOTPAK        ; 目标
        MOV        ECX,512*1024/4
        CALL    memcpy





        MOV        ESI,0x7c00        ; 源
        MOV        EDI,DSKCAC        ; 目标
        MOV        ECX,512/4
        CALL    memcpy



        MOV        ESI,DSKCAC0+512    ; 源
        MOV        EDI,DSKCAC+512    ; 目标
        MOV        ECX,0
        MOV        CL,BYTE [CYLS]
        IMUL    ECX,512*18*2/4
        SUB        ECX,512/4
        CALL    memcpy






        MOV        EBX,BOTPAK
        MOV        ECX,[EBX+16]
        ADD        ECX,3
        SHR        ECX,2
        JZ        skip
        MOV        ESI,[EBX+20]
        ADD        ESI,EBX
        MOV        EDI,[EBX+12]
        CALL    memcpy
skip:
        MOV        ESP,[EBX+12]
        JMP        DWORD 2*8:0x0000001b

waitkbdout:
        IN         AL,0x64
        AND         AL,0x02
        JNZ        waitkbdout
        RET

memcpy:
        MOV        EAX,[ESI]
        ADD        ESI,4
        MOV        [EDI],EAX
        ADD        EDI,4
        SUB        ECX,1
        JNZ        memcpy
        RET


        ALIGNB    16
GDT0:
        RESB    8
        DW        0xffff,0x0000,0x9200,0x00cf
        DW        0xffff,0x0000,0x9a28,0x0047
        DW        0
GDTR0:
        DW        8*3-1
        DD        GDT0

        ALIGNB    16
bootpack:
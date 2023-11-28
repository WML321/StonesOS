%include "boot.inc"
SECTION MBR vstart=0x7c00
  mov ax,cs
  mov ds,ax
  mov es,ax
  mov ss,ax
  mov fs,ax
  mov sp,0x7c00
  mov ax,0xb800
  mov gs,ax

  mov ax,0x600
  mov bx,0x700
  mov cx,0
  mov dx,0x1010
  int 0x10

  mov byte [gs:0x00],'A'
  mov byte [gs:0x01],0xA4

  mov byte [gs:0x02],'n'
  mov byte [gs:0x03],0x13

  mov byte [gs:0x04],'t'
  mov byte [gs:0x05],0x52

  mov byte [gs:0x06],'z'
  mov byte [gs:0x07],0xB1

  mov byte [gs:0x08],' '
  mov byte [gs:0x09],0xCC

  mov byte [gs:0x0A],'U'
  mov byte [gs:0x0B],0x2B

  mov byte [gs:0x0C],'h'
  mov byte [gs:0x0D],0x6D

  mov byte [gs:0x0E],'l'
  mov byte [gs:0x0F],0x7E

  mov byte [gs:0x10],' '
  mov byte [gs:0x11],0x49

  mov byte [gs:0x12],'K'
  mov byte [gs:0x13],0xE5

  mov byte [gs:0x14],'o'
  mov byte [gs:0x15],0x8A

  mov byte [gs:0x16],'n'
  mov byte [gs:0x17],0x96

  mov byte [gs:0x18],'e'
  mov byte [gs:0x19],0x68

  mov eax,LOADER_START_SECTOR
  mov bx,LOADER_BASE_ADDR
  mov cx,1
  call rd_disk_m_16

  jmp LOADER_BASE_ADDR

rd_disk_m_16:

  mov esi,eax
  mov di,cx
  mov dx,0x1f2
  mov al,cl
  out dx,al

  mov eax,esi

  mov dx,0x1f3
  out dx,al

  mov cl,8
  shr eax,cl
  mov dx,0x1f4
  out dx,al

  shr eax,cl
  mov dx,0x1f5
  out dx,al

  shr eax,cl
  and al,0x0f
  or al,0xe0
  mov dx,0x1f6
  out dx,al

  mov dx,0x1f7
  mov al,0x20
  out dx,al

not_ready:
  nop
  in al,dx
  and al,0x88

  cmp al,0x08
  jnz not_ready

  mov ax,di
  mov dx,256
  mul dx
  mov cx,ax

  mov dx,0x1f0

go_on_read:
  in ax,dx
  mov [bx],ax
  add bx,2
  loop go_on_read
  ret

  times 510-($-$$) db 0
  db 0x55,0xaa
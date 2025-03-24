include Irvine32.inc ; Goi thu vien


inputsize = 100 ; khai bao do dai string

.data
input db inputsize dup(0) , 0, 0 ;khai bao mang voi kich thuoc moi phan tu la 1 byte
output db inputsize dup(0), 0, 0    ; mang output
realin dd 0 ;
realout dd 0
HandleWrite HANDLE 0 ; khai bao bien kieu du lieu HANDLE(dword) co gia tri = 0
HandleRead HANDLE 0;

.code
main proc ;khai bao ham
invoke GetStdHandle, STD_OUTPUT_HANDLE ; Lay Handle output de goi WriteConsole (tra gia tri ve eax)
mov HandleWrite, eax ; Truyen ma de goi WriteConsole tu eax vao
invoke GetStdHandle, STD_INPUT_HANDLE
mov HandleRead, eax

invoke ReadConsole,
       HandleRead,
       ADDR input,
       inputsize,
       ADDR realin,
       0

mov esi, offset input   ; esi = *input
mov edi, offset output  ; edi = *output
sub realin, 2       ; tru bot 2 ky tu EOL
xor ecx, ecx        ; ecx = 0
xor eax, eax
lpush:
    cmp ecx, realin
    jz cont
    mov al, BYTE PTR [esi + ecx]   ; stack chi tiep nhan gia tri 16/32bit
    push eax
    inc ecx     ; ecx ++
    jmp lpush  ; loop lpush
cont:
    xor ecx, ecx
    xor eax, eax
lpop:
    cmp ecx, realin
    jz cont2
    pop eax
    mov BYTE PTR [edi + ecx], al
    inc ecx     ; ecx ++
    jmp lpop

cont2:

invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR output,    ; Dia chi cua mang can output
       realin,        ; Do dai cua du lieu output
       ADDR realout,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc

invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

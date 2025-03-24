include Irvine32.inc ; Goi thu vien


srcSize = 100 ; Kich thuoc string goc
fnSize = 10  ; Kich thuoc string can tim

.data
srcStr db srcSize DUP(0),0,0    ; String goc voi 2 byte EOL
fnStr db fnSize DUP(0),0,0      ; String can tim voi 2 byte EOL
HandleRead HANDLE 0; Khai bao Handle doc du lieu
HandleWrite HANDLE 0 ; khai bao Handle viet du lieu
retsrc dd 0; Gia tri thuc doc duoc cua string goc
retfn dd 0; Gia tri thuc doc duoc cua string can tim
retOut dd 0; Do dai gia tri in ra man hinh
strIndex db 3 DUP(0)

.code
find proc ; ham tim string


mov esi, offset srcStr  ; luu dia chi string goc
mov edi, offset fnStr   ; luu dia chi string can tim
sub retsrc, 2         ; do dai thuc cua string, tru eol
sub retfn, 2          ; do dai thuc cua string, tru eol
xor ecx, ecx
xor ebx, ebx            ; ebx = 0
xor edx, edx
lap:
    xor edx, edx    ; edx la index cua find string, can reset
    mov eax, ecx    ; nho vi tri dau tien giong nhau
lap1:
    mov bl, BYTE PTR [edi + edx] ; truy cap vao gia tri fnStr[edx]
    cmp bl, BYTE PTR [esi + ecx] ; truy cao vao gia tri srcStr[ecx]
    jnz lap2          ; jump neu khac nhau
    inc edx             ; neu bang nhau, tang edx len 1
    cmp edx, retfn      ; kiem tra da check het retfn
    jz lap3             ; DA TIM RA
    inc ecx             ; tang index ecx tren string goc
    jmp lap1            ; quay lai

lap3:                ; neu byte dau giong nhau, lan luot kiem tra cap
    push eax          ; bat dau tu vi tri 1
lap2:
    inc ecx
    cmp ecx, retsrc
    jnz lap
pop eax
ret
find endp ; ket thuc ham

str3 proc

xor esi, esi
mov esi, offset strIndex
mov dl, 100
div dl
mov bl, al
add bl, 30h
mov BYTE PTR [esi], bl
mov al, ah
xor ah, ah
mov dl, 10
div dl
mov bl, al
add bl, 30h
mov BYTE PTR [esi + 1], bl
mov bl, ah
add bl, 30h
mov BYTE PTR [esi + 2], bl
ret
str3 endp

main proc ;khai bao ham
; Nhap hai string
invoke GetStdHandle, STD_INPUT_HANDLE; Lay handle input goi ReadConsole
mov HandleRead, eax; luu handle tu eax vao HandleRead
invoke ReadConsole, ; goi ReadConsole
       HandleRead,  ; handle
       ADDR srcStr, ; dia chi mang srcStr
       srcSize,     ; kich thuoc du lieu
       ADDR retsrc, ; dia chi tra ve cua invoke
       0

invoke ReadConsole, ; goi ReadConsole
       HandleRead,  ; handle
       ADDR fnStr, ; dia chi mang srcStr
       fnSize,     ; kich thuoc du lieu
       ADDR retfn, ; dia chi tra ve cua invoke
       0
invoke GetStdHandle, STD_OUTPUT_HANDLE ; Lay Handle output de goi WriteConsole (tra gia tri ve eax)
mov HandleWrite, eax ; Truyen ma de goi WriteConsole tu eax vao
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR srcStr,    ; Dia chi cua mang can output
       retsrc,    ; Do dai cua du lieu output
       ADDR retOut,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR fnStr,    ; Dia chi cua mang can output
       retfn,    ; Do dai cua du lieu output
       ADDR retOut,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
call find
call str3

invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR strIndex,    ; Dia chi cua mang can output
       3,    ; Do dai cua du lieu output
       ADDR retOut,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc

invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

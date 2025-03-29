include Irvine32.inc ; Goi thu vien
; Chuong trinh nhap so phan tu cua mang n (toi da 99).
; Sau do nhap vao cac gia tri nguyen duong (0-255)
; Tim min, max trong mang roi in ra man hinh
outputsize = 12
.data
n db 2 dup(0)
count dd 0
realin dd 0;
realout dd 0 ; do dai dau ra thuc su voi kich thuoc dword co gia tri = 0
HandleWrite HANDLE 0 ; khai bao bien kieu du lieu HANDLE(dword) co gia tri = 0
HandleRead HANDLE 0
mangso dd 100 DUP(0)    ; mang cac so co toi da 100 so
arrNum db 3 dup(0)  ; cac so trong mang co 3 chu so
min db 0            ; Luu gia tri min
max db 0            ; Luu gia tri max
string1 db "Gia tri min "
string2 db "Gia tri max "
outstr db 0,0,0,0ah
outstr2 db 0,0,0,0ah
.code
strtoi proc
L1:
mov bl, BYTE PTR [eax + ecx]
cmp bl, 0dh             ; so sanh voi end of line
jz endd
cmp bl, 0Ah             ; Kiem tra LF
jz endd
sub bl, 30h             ; ASCII thanh gia tri thuc
mov BYTE PTR [eax + ecx], bl
inc ecx
jmp L1
endd:
ret
strtoi endp

itovalue proc
L2:
mov bl, BYTE PTR [eax + ecx]
cmp bl, 0dh   ; ky tu hien tai co phai eol
jz end2
imul esi, 0ah   ; ebx = ebx nhan 10
add esi, ebx
inc ecx
jmp L2 
end2:
ret
itovalue endp

itostr proc     ; ham doc gia tri trong esi va bien no thanh string 3 chu so
; luu trong array [esi]
mov cl, 10

div cl  ; chia ax cho 10
add ah, 30h
mov BYTE PTR [esi + 2], ah
xor ah, ah          ; Xoa phan du trong ah de ax chi con gia tri cua thuong
div cl
add ah, 30h
mov BYTE PTR [esi + 1], ah
xor ah, ah          ; Xoa phan du
div cl
add ah, 30h
mov BYTE PTR [esi], ah
xor ah, ah

ret
itostr endp

main proc ;khai bao ham
invoke GetStdHandle, STD_INPUT_HANDLE
mov HandleRead, eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov HandleWrite, eax
invoke ReadConsole,     ; lay so phan tu cua mang
        HandleRead,
        ADDR n,
        4,          ; input size
        ADDR realin,
        0
; Tham so cua proc strtoi la dia chi mang eax, ecx = 0, ebx = 0
mov eax, offset n   ; eax luu offset cua n
xor ecx, ecx    ; xoa ecx
xor ebx, ebx    ; xoa ebx
call strtoi     ; goi strtoi

; Ham itovalue, giu nguyen eax tu strtoi
; bien mang gia tri thanh so (eax dang = offset n)
; Can xoa ebx, ecx, esi. Gia tri tra ve esi
xor ebx, ebx    ; xoa ebx
xor ecx, ecx
xor esi, esi
call itovalue

mov count, esi  ; truyen gia tri esi tu proc vao count
; Nhap so cho mang
xor edx, edx    ; xoa ecx lam bo dem

mov edi, offset mangso   ; edi luu offset cua mangso
L3:
cmp edx, count
jz end3
push edx    ; luu edx len stack
invoke ReadConsole,
        HandleRead,
        ADDR arrNum,    ; truyen vao string so
        5,              ; doc 3 so + 0dh,0ah
        ADDR realin,    ; so ky tu that su nhap
        0
; Tham so cua proc strtoi la dia chi mang eax, ecx = 0, ebx = 0
pop edx     ; lay lai edx sau loi goi invoke
mov eax, offset arrNum   ; eax luu offset cua arrNum
xor ecx, ecx    ; xoa ecx
xor ebx, ebx    ; xoa ebx
call strtoi     ; goi strtoi

; Ham itovalue, giu nguyen eax tu strtoi
; bien mang gia tri thanh so (eax dang = offset mang)
; Can xoa ebx, ecx, esi. Gia tri tra ve esi
xor ebx, ebx    ; xoa ebx
xor ecx, ecx
xor esi, esi
call itovalue
shl edx, 2                ; edx = edx * 4
mov DWORD PTR [edi + edx], esi    ; chuyen ket qua esi vao mang
shr edx, 2                ; turn edx back
inc edx             ; edx ++
jmp L3              ; loop L3

end3:

; Phase tim min max
xor eax, eax    ;eax = 0
xor ebx, ebx    ;ebx = 0
xor ecx, ecx    ;ecx = 0

mov esi, offset mangso
mov al, BYTE PTR [esi]  ; thanh ghi min
mov bl, BYTE PTR [esi]  ; thanh ghi max
lap:
    inc cl ; ecx ++
    cmp cl, BYTE PTR count
    jz endi
    cmp al, BYTE PTR [esi + ecx * 4]   ; mangso la doubleword (4byte)
    ja thaymin
    cmp bl, BYTE PTR [esi + ecx * 4]
    jb thaymax
    jmp lap
thaymin:
    mov al, BYTE PTR [esi + ecx * 4]
    jmp lap
thaymax:
    mov bl, BYTE PTR [esi + ecx * 4]
    jmp lap
endi:
mov esi, offset outstr
call itostr
mov esi, offset outstr2
xor eax, eax    ; retset eax
mov al, bl
call itostr
; In ketqua
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR string1,    ; Dia chi cua mang can output
       outputsize,    ; Do dai cua du lieu output
       ADDR realout,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR outstr,    ; Dia chi cua mang can output
       4,    ; Do dai cua du lieu output
       ADDR realout,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR string2,    ; Dia chi cua mang can output
       outputsize,    ; Do dai cua du lieu output
       ADDR realout,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
invoke WriteConsole, ; goi WriteConsole de thuc hien output
       HandleWrite,   ; Handle de thuc hien lenh
       ADDR outstr2,    ; Dia chi cua mang can output
       4,    ; Do dai cua du lieu output
       ADDR realout,  ; Do dai thuc su cua du lieu output
       0              ; Ket thuc doc
invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

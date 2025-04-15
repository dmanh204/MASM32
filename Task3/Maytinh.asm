include Irvine32.inc ; Goi thu vien

; Input chi nhap so duong!!

.data
dauam db 2Dh
luachon db "Chon phep toan:", 0dh, 0ah
cong db "1. Cong", 0dh, 0ah
tru db "2. Tru", 0dh, 0ah
nhan db "3. Nhan", 0dh, 0ah
chia db "4. Chia", 0dh, 0ah
du db "Du = "
ketq db "Ket qua = "
xuongdong db 0dh, 0ah
choice db 0, 0, 0
count db 0		; dem so chu so trong numtostr
giatri1 dd 0
giatri2 dd 0
strIn db 20 dup(0), 0
strOut db 20 dup(0), 0
realIn dd 0 ; do dai dau ra thuc su voi kich thuoc dword co gia tri = 0
hIn HANDLE 0 ; khai bao bien kieu du lieu HANDLE(dword) co gia tri = 0
realOut dd 0
hOut HANDLE 0
.code
; push giatri, push strIn
strtonum proc
; push offset string so
; push offset giatri so
pushad
mov esi, [esp + 36]
mov edi, [esp + 40]
mov ecx, 0
mov ebx, 0
mov edx, 0
mov ebp, 10
mov eax, 0		; edx chua tong gia tri
L1:
mov bl, byte ptr [esi + ecx]
cmp bl, 0Dh			; ket thuc chuoi nhap la 0Dh, 0Ah
jz T1
mul ebp
sub bl, 30h		; giam ve gia tri
add eax, ebx
inc ecx
jmp L1
T1:
mov [edi], eax
popad
ret
strtonum endp

; push offset output, push giatri
numtostr proc
pushad
mov ebp, 10	; chia he so 10
mov ecx, 0
mov eax, [esp + 36]
mov esi, [esp + 40]
day:
xor edx, edx
div ebp		; edx:eax chia 10, thuong eax, du edx
push edx	; day du len stack
inc ecx
cmp eax, 0
jz keo
jmp day
keo:
mov count, cl
xor ecx, ecx
L2:
cmp cl, count
jz T2
pop edx
add dl, 30h		; chuyen thanh ky tu ASCII
mov byte ptr [esi + ecx], dl
inc ecx
jmp L2
T2:
popad
ret
numtostr endp

main proc ;khai bao ham
invoke GetStdHandle, STD_INPUT_HANDLE
mov hIn, eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hOut, eax
invoke WriteConsole, hOut, addr luachon, 17, addr realOut, 0
invoke WriteConsole, hOut, addr cong, 9, addr realOut, 0
invoke WriteConsole, hOut, addr tru, 8, addr realOut, 0
invoke WriteConsole, hOut, addr nhan, 9, addr realOut, 0
invoke WriteConsole, hOut, addr chia, 9, addr realOut, 0

invoke ReadConsole, hIn, addr choice, 3, addr realIn, 0
invoke ReadConsole, hIn, addr strIn, 20, addr realIn, 0
push offset giatri1
push offset strIn
call strtonum
pop ecx
pop ecx		; ecx chua gia tri khong dung nua

invoke ReadConsole, hIn, addr strIn, 20, addr realIn, 0
push offset giatri2
push offset strIn
call strtonum
pop ecx
pop ecx

invoke WriteConsole, hOut, addr ketq, 10, addr realOut, 0

mov esi, offset choice
mov bl, byte ptr [esi]
cmp bl, 31h	; Neu la cong
jnz pheptru
mov eax, giatri1
mov edx, giatri2
add eax, edx
mov giatri1, eax
jmp ed
pheptru:
cmp bl, 32h ; Neu la tru
jnz phepnhan
mov eax, giatri1
mov edx, giatri2
cmp eax, edx
jl truAm
sub eax, edx
mov giatri1, eax
jmp ed
truAm:
sub edx, eax
mov giatri1, edx
invoke WriteConsole, hOut, addr dauam, 1, addr realOut, 0	; Viet dau -
jmp ed
phepnhan:
cmp bl, 33h	; Neu la nhan
jnz phepchia
mov eax, giatri1
mov ebx, giatri2
mul ebx		; KQ = edx:eax, gia su chi nhan trong 32 bit thi chi co eax
mov giatri1, eax
jmp ed
phepchia:
mov eax, giatri1
mov ebx, giatri2
xor edx, edx
div ebx
mov giatri1, eax	; thuong
mov giatri2, edx	; du
jmp ed2
ed:
push offset strOut
push giatri1
call numtostr
pop ecx
pop ecx
invoke WriteConsole, hOut, addr strOut, count, addr realOut, 0
jmp xong
ed2:
push offset strOut
push giatri1
call numtostr
pop ecx
pop ecx
invoke WriteConsole, hOut, addr strOut, count, addr realOut, 0
invoke WriteConsole, hOut, addr xuongdong, 2, addr realOut, 0
invoke WriteConsole, hOut, addr du, 5, addr realOut, 0
push offset strOut
push giatri2
call numtostr
pop ecx
pop ecx
invoke WriteConsole, hOut, addr strOut, count, addr realOut, 0
xong:
invoke ExitProcess,0 ; Ket thuc qua trinh va thoat

main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

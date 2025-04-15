include Irvine32.inc ; Goi thu vien


.data
S db 256 dup(0), 0
T db 256 dup(0), 0

key db 256 dup(0), 0
plaintext db 256 dup(0), 0
space db " ", 0
nhapKey db "Nhap Key: ", 0
nhapPlaintext db "Nhap Plaintext: ", 0
hexbyte db 0,0
hIn HANDLE 0
hOut HANDLE 0
realIn dd 0
realOut dd 0

.code
mod256 proc
xor ebx, ebx
xor edx, edx
mov bx, 256
div bx								; dx:ax chia bx; thuong = ax, du = dx 
mov ax, dx							; ax = du
ret
mod256 endp
hextoi proc
pushad
xor eax, eax
xor ebx, ebx
mov edi, offset hexbyte
mov al, byte ptr [esp + 36]
mov bl, 1111b
and bl, al		;
cmp bl, 0ah
jl so
add bl, 37h
jmp tt
so:
add bl, 30h
tt:
mov [edi + 1], bl
shr al, 4
cmp al, 0ah
jl so2
add al, 37h
jmp tt2
so2:
add al, 30h
tt2:
mov [edi], al

invoke WriteConsole, hOut, addr hexbyte, 2, addr realOut, 0
invoke WriteConsole, hOut, addr space, 1, addr realOut, 0
popad
ret
hextoi endp

sinhkhoa proc
mov edi, offset S
inc ecx
cmp ecx, 256
jnz koreset
mov ecx, 0
koreset:
xor ebx, ebx
mov bl, byte ptr [edi + ecx]	; bl  = S[i]
add ax, bx						; j = j + S[i]
mov bx, 256
xor edx, edx
div bx							; dx:ax chia bx, thuong ax, du dx
mov ax, dx
; Hoan doi S[i], S[j]
xor ebx, ebx
mov bl, byte ptr [edi + eax]		; S[j]
mov bh, byte ptr [edi + ecx]		; S[i]
mov byte ptr [edi + ecx], bl
mov byte ptr [edi + eax], bh

xor edx, edx
mov dl, bl
shr ebx, 8
add bx, dx
cmp bx, 256
jl ok
sub bx, 256
ok:
mov bl, byte ptr [edi + ebx]
ret
sinhkhoa endp

main proc ;khai bao ham
invoke GetStdHandle, STD_INPUT_HANDLE
mov hIn, eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hOut, eax

invoke WriteConsole, hOut, addr nhapKey, 10, addr realOut, 0
invoke ReadConsole, hIn, addr key, 256, addr realIn, 0
	; realIn = keylength
sub realIn, 2		; loai bo 0ah, 0dh

; Initialize
mov ecx, 0
mov edi, offset S
mov esi, offset T
mov ebp, offset key
mov ebx, realIn
L1:
cmp ecx, 256
jz T1
mov byte ptr [edi + ecx], cl		; Gan gia tri 0-255 cho S[i]

mov eax, ecx
div bl			; ax chia bl, thuong = al, du = ah
shr eax, 8
mov dl, byte ptr  [ebp + eax]		; dl = key[i%len]
mov byte ptr [esi + ecx], dl		; T[i] = dl
inc ecx
jmp L1
T1:
; Hoan doi byte S
mov ecx, 0		; ecx = i
mov eax, 0		; eax = j
L2:
xor ebx, ebx
xor edx, edx
cmp ecx, 256
jz T2
mov bl, byte ptr [edi + ecx]		; bl = S[i]
mov dl, byte ptr [esi + ecx]		; dl = T[i]
add bx, dx							; bx = S[i] + T[i]
add ax, bx							; j  = j + S[i] + T[i]
mov bx, 256
xor edx, edx				; phep chia dung dx:ax nen can xoa dx
div bx								; dx:ax chia bx; thuong = ax, du = dx 
mov ax, dx							; ax = du
xor ebx, ebx
mov bl, byte ptr [edi + eax]		; S[j]
mov bh, byte ptr [edi + ecx]		; S[i]
mov byte ptr [edi + ecx], bl
mov byte ptr [edi + eax], bh

inc ecx
jmp L2
T2:
; Ket thuc Initialize. Matrix S[i] is ready. Da kiem tra, S[i] chinh xac

; Doc plaintext
invoke WriteConsole, hOut, addr nhapPlaintext, 16, addr realOut, 0
invoke ReadConsole, hIn, addr plaintext, 256, addr realIn, 0
sub realIn, 2
mov ebp, 0
mov esi, offset plaintext
xor eax, eax
xor ecx, ecx
mahoa:
cmp ebp, realIn
jz endd
call sinhkhoa		; kq luu trong bl

xor edx, edx
mov dl, byte ptr [esi + ebp]
xor dl, bl			; ma hoa

push edx
call hextoi
pop edx
inc ebp
jmp mahoa

endd:
invoke ExitProcess,0 ; Ket thuc qua trinh va thoat

main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

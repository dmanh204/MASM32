include Irvine32.inc ; Goi thu vien

len = 32	; Chieu dai chuoi nhap vao 32 byte
.data
so1 byte len DUP(?),0,0		; string duoc nhap + 2 byte 0dh,0ah
so2 byte len DUP(?),0,0		; string 2
tong byte len DUP(0),0;0	; string chua tong 2 so
inHand HANDLE ?				; Handle input
outHand HANDLE ?			; Handle output
retIN1 dword ?				; So byte cua gia tri input
retIN2 dword ?				; So byte cua gia tri input 2
retOUT dword ?				; So byte cua gia tri output
diachi1 dword ?				; Dia chi so1
diachi2 dword ?				; Dia chi so2
carry byte 0				; gia tri nho
phugia byte 0				; luu so chu so cua so ngan hon
.code
cong proc uses ESI EDI EBX EBP
mov esi, OFFSET so1		; esi = dia chi so1
mov edi, OFFSET so2		; edi = dia chi so2
mov ebp, OFFSET tong	; ebp = dia chi tong

mov ecx, retIN1			; ecx = leng of so1
cmp ecx, retIN2			; so sanh do dai
jbe l1					; neu m <= n thi ecx = m
mov ecx, retIN2			; neu m > n thi ecx = n
mov eax, retIN1
sub eax, ecx

l1:
mov eax, retIN2
sub eax, ecx

sub ecx, 2
loop1:
mov dl, BYTE PTR [esi + ecx - 1]	; edx = tung chu so cua so1
sub dl, 30h						; ky tu so ASCII lon hon 30h so voi gia tri bit
mov bl, BYTE PTR [edi + ecx - 1]	; ebx = tung chu so cua so2
sub bl, 30h						; ky tu so ASCII lon hon 30h so voi gia tri bit
add dl, bl						; cong hai chu so
add dl, carry						; cong voi gia tri nho
cmp dl, 0ah						; so sanh voi 10 (decimal)
jb konho
sub dl, 0ah						; tru di phan lon hon 10
mov carry, 1						; gia tri carry = 1
jmp tiep

konho:
mov carry, 0						; gia tri carry = 0

tiep:
add dl, 30h						; dua gia tri trong edx ve ma ASCII

mov BYTE PTR [ebp + ecx + eax - 1], dl; dua vao string tong
loop loop1

mov edx, retIN1			; edx = retIN1
cmp edx, retIN2			; so sanh do dai

ja l2					; neu m <= n thi ecx = n - m
sub edx, retIN2			; neu m > n thi edx = m - n
mov ecx, edx
jmp loop2
l2:
mov ecx, retIN2
sub ecx, retIN1

cmp ecx, 0h
je ed

jmp loop3
loop2:
	mov bl, BYTE PTR[esi + ecx - 1]
	sub bl, 30h
	add bl, carry
	cmp bl, 0ah
	jae nho
	mov carry, 0
	jmp tiep2
nho: 
	mov carry, 1
	sub bl, 0ah
tiep2:
add bl, 30h						; dua gia tri trong edx ve ma ASCII
mov BYTE PTR [ebp + ecx - 1], bl; dua vao string tong
loop loop2
jmp ed

loop3:
	mov bl, BYTE PTR[edi + ecx - 1]
	sub bl, 30h
	add bl, carry
	cmp bl, 0ah
	jae nho2
	mov carry, 0
	jmp tiep3
nho2: 
	mov carry, 1
	sub bl, 0ah
tiep3:
add bl, 30h						; dua gia tri trong edx ve ma ASCII
mov BYTE PTR [ebp + ecx - 1], bl; dua vao string tong
loop loop3

ed:
cong endp

main proc
invoke GetStdHandle, STD_INPUT_HANDLE; Lay input handle
mov inHand, eax						; Luu vao inHand
invoke ReadConsole,
		inHand,				; handle input
		ADDR so1,			; dia chi string
		len,				; chieu dai
		ADDR retIN1,			; dia chi tra ve
		0
invoke ReadConsole,
		inHand,				; handle input
		ADDR so2,			; dia chi string
		len,				; chieu dai
		ADDR retIN2,			; dia chi tra ve
		0

call cong

xor eax, eax							; eax = 0, loai bo gia tri cu
invoke GetStdHandle, STD_OUTPUT_HANDLE; Lay output
mov outHand, eax						; lay handle trong eax
invoke WriteConsole,					; invoke 
		outHand,						; handle
		ADDR tong,						; dia chi string
		len,							; chieu dai string
		ADDR retOUT,					; dia chi tra ve
		0

main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

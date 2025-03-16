include Irvine32.inc ; Goi thu vien

len = 32	; Chieu dai chuoi nhap vao 32 byte
.data
strng byte len DUP(?),0,0		; string duoc nhap + 2 byte 0dh,0ah
inHand HANDLE ?				; Handle input
outHand HANDLE ?			; Handle output
retIN dword ?				; Gia tri tra ve khi input
retOUT dword ?				; Gia tri tra ve khi output

.code

main proc
invoke GetStdHandle, STD_INPUT_HANDLE; Lay input handle
mov inHand, eax						; Luu vao inHand
invoke ReadConsole,
		inHand,				; handle input
		ADDR strng,			; dia chi string
		len,				; chieu dai
		ADDR retIN,			; dia chi tra ve
		0

mov ecx, retIN				; truyen do dai string vao ecx
sub ecx, 2					; tru di 2 ky tu end of line
mov ebx, OFFSET strng		; truyen vao offset cua string
l1:
	mov al, BYTE PTR [ebx + ecx - 1]	; truyen byte vi tri string [n- cx] vao al
	cmp al, 61h							; neu byte < 61h (a) thi sang vong lap moi
	jb check
	cmp al, 7ah							; neu byte > 7ah (z) thi sang vong lap moi
	ja check
	sub al, 20h							; ky tu hoa cach ky tu thuong 20h
	mov BYTE PTR [ebx + ecx - 1], al	; ghi lai ky tu moi vao string
check:	loop l1							; thuc hien vong lap ecx lan

xor eax, eax							; eax = 0, loai bo gia tri cu
invoke GetStdHandle, STD_OUTPUT_HANDLE; Lay output
mov outHand, eax						; lay handle trong eax
invoke WriteConsole,					; invoke 
		outHand,						; handle
		ADDR strng,						; dia chi string
		len,							; chieu dai string
		ADDR retOUT,					; dia chi tra ve
		0

main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

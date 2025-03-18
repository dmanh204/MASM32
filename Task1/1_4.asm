include Irvine32.inc ; Goi thu vien
; ASCII Addition
; Chuong trinh nay nhan 2 gia tri string integer,
; Tien hanh cong ASCII 2 string nay bang 'AAA' instruction
; In ket qua ra man hinh

 SizeIn = 6 ; khai bao do dai string

.data
strIN1 BYTE SizeIN DUP(0),0
strIN2 BYTE SizeIN DUP(0),0
sum BYTE SizeIN+1 DUP(0),0
inHand HANDLE ?
outHand HANDLE ?
retIN1 DWORD ?
retIN2 DWORD ?
retOUT DWORD ?

.code
main proc ;khai bao ham
; Doc 2 gia tri
invoke GetStdHandle, STD_INPUT_HANDLE	
mov inHand, eax

invoke ReadConsole,
		inHand,
		ADDR strIN1,
		SizeIN,
		ADDR retIN1,
		0

invoke ReadConsole,
		inHand,
		ADDR strIN2,
		SizeIN,
		ADDR retIN2,
		0

; Start at the last digit position.
mov esi, retIn1 - 1
mov edi, retIn1
mov ecx, retIn1
mov bh, 0		; set carry = 0
L1: mov ah, 0	; clear AH before addition
	mov al, strIN1[esi]		; get the first digit
	add al, bh				; add previous carry
	aaa						; use aaa to adjust the sum
	mov bh, ah				; save the carry to carry1 (bh)
	or bh, 30h				; convert to ASCII
	add al, strIN2[esi]		; add the second digit
	aaa
	or bh, ah				; or the carry with carry1
	or bh, 30h				; convert
	or al, 30h				; convert AL to ASCII
	mov sum[edi],al			; save to sum
	dec esi				;
	dec edi
	loop L1
mov sum[edi], bh			; save last carry digit

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outHand, eax
invoke WriteConsole,
		outHand,
		ADDR sum,
		7,
		ADDR retOUT,
		0

invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

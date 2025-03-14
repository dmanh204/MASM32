include Irvine32.inc ; Goi thu vien

outputsize = 13 ; khai bao do dai dau ra

.data
msg byte "Hello,world!",0 ; Chuoi string in len man hinh console
actualout dword ? ; so byte that su viet len man hinh, duoc tra ve bien nay sau khi thuc hien
handler Handle 0 ; Handle OUTPUT ra console.

.code
main proc ;khai bao ham
invoke GetStdHandle, STD_OUTPUT_HANDLE ; Lay console outout handle, cho vao eax
mov handler, eax ; Luu gia tri handle vao handler

; Goi WriteConsole
invoke WriteConsole,
	handler,		; truyen vao handle
	ADDR msg,		; truyen vao dia chi string
	outputsize,		; truyen vao string length
	ADDR actualout,	; truyen vao dia chi tra ve so byte duoc viet
	0				; khong su dung lpReserved

invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

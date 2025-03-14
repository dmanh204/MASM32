include Irvine32.inc ; Goi thu vien


buf = 32 ; khai bao do dai input

.data
buffer Byte buf DUP(?),0,0 ; Hai byte 0 de chua ky tu EOL 0dh,0ah
handler Handle ?           ; Khai bao Handle
input Dword ?              ; Khai bao gia tri tra ve so byte input that su
outHand Handle ?           ; Khai bao handle output
output Dword ?             ; Khai bao gia tri tra ve so byte output

.code
main proc ;khai bao ham
invoke GetStdHandle, STD_INPUT_HANDLE ; Lay Handle input de goi ReadConsole (tra gia tri ve eax)
mov handler, eax ; Truyen ma de goi ReadConsole tu eax vao
invoke ReadConsole,     ; goi ReadConsole de thuc hien input
       handler,         ; Handle de thuc hien lenh
       ADDR buffer,     ; Dia chi cua mang nhan input
       buf,             ; Do dai cua du lieu input
       ADDR input,      ; Do dai thuc su cua du lieu input
       0                ; Ket thuc doc

; Hien thi buffer len console
invoke GetStdHandle, STD_OUTPUT_HANDLE ; Lay Handle output goi WriteConsole, luu vao eax
mov outHand, eax

invoke WriteConsole,    ; Goi WriteConsole
       outHand,       ; handle output
       ADDR buffer,     ; dia chi string in ra console
       buf,             ; kich thuoc
       ADDR output,     ; dia chi gia tri tra ve
       0

invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

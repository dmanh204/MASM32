include Irvine32.inc ; Goi thu vien
; Dung thu vien cua Irvine32
outputsize = 32 ; khai bao do dai dau ra

.data

sum dd 0;
.code
main proc ;khai bao ham
call ReadInt
mov sum, eax
call ReadInt
add eax, sum
call WriteInt


invoke ExitProcess,0 ; Ket thuc qua trinh va thoat


main endp ; ket thuc ham main
end main  ; ket thuc chuong trinh

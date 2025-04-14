.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc

include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib

Process32First PROTO :HANDLE, :DWORD
Process32Next PROTO :HANDLE, :DWORD
.data
	; Browser name
chrome db "chrome.exe", 0
edge db "msedge.exe", 0
firefox db "firefox.exe", 0
opera db "opera.exe", 0

	; Handle
hSnapshot HANDLE ?
hTerminate HANDLE ?

PE32 PROCESSENTRY32 <>	; struct chua thong tin process, lay tu snapshot

.code
cmpStr proc
mov esi, [esp + 4]	; offset ten trinh duyet
mov edi, [esp + 8]	; offset PE32.szExeFile

xor eax, eax
xor ecx, ecx

L0:
	mov al, byte ptr [esi + ecx]
	mov ah, byte ptr [edi + ecx]
	cmp ah, al
;IF ah != al
	jnz notequal
;ELSE	(ah == al)
	cmp ah, 0
	;IF ah == al == 0
		jz equa
	;ELSE  (ah != 0)
		inc ecx
		jmp L0
notequal:
	mov eax, 0
	jmp ed
equa:
	mov eax, 1
ed:
ret
cmpStr endp

Terminate proc
invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0		; Tao snapshort ghi lai tat ca process hien tai
mov hSnapshot, eax					; luu Handle
cmp hSnapshot, INVALID_HANDLE_VALUE
jz Ketthuc
;IF VALID_HANDLE_VALUE
	mov PE32.dwSize, SIZEOF PROCESSENTRY32
	invoke Process32First, hSnapshot, ADDR PE32		; Duyet Process dau tien trong hSnapshot bang struct PE32
	cmp eax, 0
	;IF invalid
		jz Ketthuc
	;ELSE
LP:
	push offset PE32.szExeFile			; ten file thuc thi cua process
	push offset chrome					;
	call cmpStr
	pop ecx								; Lay du lieu ra khoi stack
	pop ecx								; Lay du lieu ra khoi stack
	cmp eax, 1
	jz Dong

	push offset PE32.szExeFile			; ten file thuc thi cua process
	push offset edge					;
	call cmpStr
	pop ecx								; Lay du lieu ra khoi stack
	pop ecx								; Lay du lieu ra khoi stack
	cmp eax, 1
	jz Dong

	push offset PE32.szExeFile			; ten file thuc thi cua process
	push offset firefox					;
	call cmpStr
	pop ecx								; Lay du lieu ra khoi stack
	pop ecx								; Lay du lieu ra khoi stack
	cmp eax, 1
	jz Dong

	push offset PE32.szExeFile			; ten file thuc thi cua process
	push offset opera					;
	call cmpStr
	pop ecx								; Lay du lieu ra khoi stack
	pop ecx								; Lay du lieu ra khoi stack
	cmp eax, 1
	jz Dong
	jmp Tieptuc

Dong:
	invoke OpenProcess, PROCESS_TERMINATE, FALSE, PE32.th32ProcessID	; lay Handle Tien trinh voi quyen terminate.
	mov hTerminate, eax
	invoke TerminateProcess, hTerminate, 0
Tieptuc:
	invoke Process32Next, hSnapshot, addr PE32
	cmp eax, 0
	jz Ketthuc
	jmp LP
Ketthuc:
ret
Terminate endp
main proc
main endp
call Terminate
invoke ExitProcess, 0
end main

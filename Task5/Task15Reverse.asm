.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc

include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib

include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

include \masm32\include\gdi32.inc
includelib \masm32\lib\gdi32.lib

.data

; tham so khoi tao chuong trinh, (main proc)
CommandLine LPSTR ?		; CommandLine cua chuong trinh
HInstance HINSTANCE	?	; handle instance cua chuong trinh

; tham so dung trong WinMain
	; Khoi tao cua so
wnd WNDCLASSEX	<?>		; struct WindowClassEx
	; Goi CreateWindowEx
ClassName db "CLN1", 0		; Chuoi dinh danh cho object Class Window
WinName db "Reverse", 0		; Ten cua cua so
	; Vong lap message
msg MSG	<?>				; tin nhan trao doi trong instance

; tham so dung trong WndProc
hdc HDC	?				; handle Device Context, dung de hien thi
classedit db "edit", 0
classbutton db "OK",0
HIn	HWND ?	; handle cua so con
HOut HWND ?	; handle cua so con

buffer db 256 dup(0),0 
output db 256 dup(0), 0
IDM_GETTEXT equ 3

.code

WinMain proc hInstance:HINSTANCE, hPrevInst: HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
LOCAL handW:HWND

mov wnd.cbSize, SIZEOF WNDCLASSEX
mov wnd.style, CS_HREDRAW or CS_VREDRAW
mov wnd.lpfnWndProc, offset WndProc
mov wnd.cbClsExtra, 0
mov wnd.cbWndExtra, 0
push HInstance
pop wnd.hInstance
invoke LoadIcon, NULL, IDI_APPLICATION
mov wnd.hIcon, eax
mov wnd.hIconSm, eax
invoke LoadCursor, NULL, IDC_ARROW
mov wnd.hCursor, eax
mov wnd.hbrBackground, COLOR_WINDOW+0
mov wnd.lpszMenuName, 0
mov wnd.lpszClassName, offset ClassName

invoke RegisterClassEx, addr wnd
invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName, addr WinName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 300, 200, 0, 0, HInstance, 0
mov handW, eax		; truyen handle cua cua so vua tao vao handW

invoke ShowWindow, handW, SW_SHOW
invoke UpdateWindow, handW

MesLP:
invoke GetMessage, ADDR msg, 0, 0, 0
cmp eax, 0
jz EXIT
invoke TranslateMessage, ADDR msg
invoke DispatchMessage, ADDR msg
jmp MesLP
EXIT:
ret 
WinMain endp

WndProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL rect: RECT
LOCAL hbr: DWORD

.IF uMsg == WM_CREATE
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr classedit, NULL, WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL or ES_LEFT, 20, 20, 200, 30, hwnd, 1001, HInstance, NULL
	mov HIn, eax
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr classedit, NULL, WS_CHILD or WS_VISIBLE or ES_AUTOHSCROLL or ES_LEFT, 20, 70, 200, 30, hwnd, NULL, HInstance, NULL
	mov HOut, eax
	
.ELSEIF uMsg == WM_DESTROY
	invoke PostQuitMessage, NULL
.ELSEIF uMsg == WM_COMMAND
	mov eax, wParam
	.IF lParam == 0
		.IF ax == IDM_GETTEXT
			invoke GetWindowText, HIn, ADDR buffer, 256		; GetWindowText, truyen vao buffer
            mov eax, offset buffer
            xor ecx, ecx
            mov ebx, 0
            push ebx
            xor ebx, ebx
            Day:
            mov bl, BYTE PTR [eax + ecx]
            cmp bl, 0
            jz Cont
            push ebx	; day len stack
            inc ecx		; tang gia tri ecx
            jmp Day
            Cont:
			mov eax, offset output
			xor ecx, ecx
			Lay:
            pop ebx		; lay ra tu stack
            cmp bl, 0
            jz Xong
            mov BYTE PTR [eax + ecx], bl
            inc ecx
            jmp Lay
            Xong:

			invoke SetWindowText, HOut, ADDR output			; SetWindowText lay tu buffer
		.ENDIF
	.ELSE			; lParam khac 0 khi nhap lieu, nguoi dung bam nut. lParam bang 0 khi xu ly noi bo?
		.IF ax == 1001
			shr eax, 16
			.IF ax == EN_CHANGE			; khi noi dung edit text thay doi
				invoke SendMessage, hwnd, WM_COMMAND, IDM_GETTEXT, 0	; gui Message WM_COMMAND va wParam chua IDM_GETTEXT
			.ENDIF
		.ENDIF
	.ENDIF
.ELSE
	invoke DefWindowProc, hwnd, uMsg, wParam, lParam
.ENDIF
ret
WndProc endp
; bat dau chuong trinh
main proc
invoke GetModuleHandle, 0
mov HInstance, eax

invoke GetCommandLine
mov CommandLine, eax

invoke WinMain, HInstance, 0, CommandLine, SW_SHOW
invoke ExitProcess, 0
main endp

end main
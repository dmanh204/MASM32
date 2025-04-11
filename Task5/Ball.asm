.386			; Kien truc 32 bit
.model flat, stdcall		; mo hinh memory, kich thuoc code, data pointer
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
include \masm32\include\gdi32.inc		; Thu vien do hoa Graphics Device Interface.
includelib \masm32\lib\gdi32.lib		; Cho phep ve do hoa LineTo, Rectangle, Ellipse
										; hien thi font, color

CheckEllipse proto :DWORD, :DWORD, :DWORD, :DWORD

.data
wnd WNDCLASSEX <?>
Namee db "Ball", 0
Hinstance HINSTANCE ?			; From \masm32\include\windows.inc
								; la handle tham chieu den mot instance cua ung dung trong Windows

msg MSG <?>						; From \masm32\include\windows.inc
								; la struct chua thong tin ve mot Message trong hang doi tin nhan cua ung dung
								; bao gom fields: hwnd, message, wParam, lParam, time, pt

paintst PAINTSTRUCT <?>			; \masm32\include\windows.inc
								; la struct chua thong tin ve giao dien, lien quan den GDI

STIME SYSTEMTIME <?>			; \masm32\include\windows.inc
								; la struct chua thong tin thoi gian he thong, ngay thang thang, gio phut giay

act db 0
hPen HPEN ?						; \masm32\include\windows.inc
								; handle tro toi PEN trong GDI, dung de ve duong thang, vien; lien quan den GDI

hBrush HBRUSH ?					; \masm32\include\windows.inc
								; handle tro toi BRUSH trong GDI, dung de to mau nen; lien qua den GDI

hdc HDC ?						; \masm32\include\windows.inc
								; handle tro toi Device Context, dung de ve do hoa; lien quan den GDI
SOFB dw 30
topleft POINT <>				; \masm32\include\windows.inc
								; struct chua toa do (x,y) 2D
bottomright POINT <>
CommandLine LPSTR ?				; \masm32\include\windows.inc
								; pointer kieu chuoi ky tu, luu tru chuoi dang ANSI
								; co the duoc dung de luu tham so dong lenh tu ham getcommandline
ClassName db "UUU", 0
vectorX dd 8h
vectorY dd 8h

.data?
Random dd ?

.code
;Windows API yeu cau cac callback timer function duoc SetTimer goi can khai bao
	; VOID CALLBACK <name>(HWND hwnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime);
	; - HWND: con tro 32bit, handle cua cua so lien ket voi timer
	;	khi goi SetTimer, handle nay duoc truyen vao callback
	; - message: ma thong diep windows gui toi callback, thuong la WM_TIMER = 0x0113
	; - idEvent: id cua timer
	; - dwTime: thoi gian he thong hien tai, thoi diem timer duoc kich hoat.
TimerProc proc Timehwnd:HWND, uMsg:UINT, idEvent:UINT, dwTime:DWORD
invoke InvalidateRect, Timehwnd, 0, TRUE
ret
TimerProc endp
; Sau moi khoang thoi gian x, Timer goi TimerProc. Trong TimerProc, toan bo cua so tro boi Timehwnd la khong hop le, yeu cau ve lai


; Ham callback WndProc nhan message tu messageloop, xu ly message

WndProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL rect: RECT
LOCAL hbr: DWORD
.IF uMsg == WM_DESTROY				; neu cua so bi dong, goi PostQuitMessage, chuan bi ket thuc
	invoke PostQuitMessage, NULL
.ELSEIF	uMsg == WM_PAINT			; WM_PAINT - can ve lai cua so
; Bat dau ve
	invoke BeginPaint, hwnd, addr paintst	; khoi tao device context hdc, luu trong paintst
	invoke GetStockObject, DEFAULT_GUI_FONT	; lay net but
	mov hbr, eax							; luu handle vao hbr

; Lay kich thuoc vung client area, luu vao rect
	invoke GetClientRect, hwnd, addr rect			; cap nhat toa do cua so
	invoke FillRect, paintst.hdc, addr rect, hbr	; to nen bang bush 'hbr'
	invoke SelectObject, paintst.hdc, hPen			; chon nen va but
	invoke SelectObject, paintst.hdc, hBrush
; invoke CheckEllipse kiem tra toa do Ellipse
	invoke CheckEllipse, rect.left, rect.top, rect.right, rect.bottom
	call moveEllipse
	invoke Ellipse, paintst.hdc, topleft.x, topleft.y, bottomright.x, bottomright.y
	invoke EndPaint, hwnd, addr paintst
.ELSEIF uMsg == WM_TIMER
	invoke GetDC, hwnd					; get Device Context, luu vao hdc
	mov hdc, eax

	invoke GetStockObject, 0
	mov hbr, eax

	invoke GetClientRect, hwnd, addr rect
	invoke FillRect, hdc, addr rect, hbr
	invoke SelectObject, hdc, hPen
	invoke SelectObject, hdc, hBrush

	call moveEllipse
	invoke Ellipse, hdc, topleft.x, topleft.y, bottomright.x, bottomright.y
	invoke ReleaseDC, hwnd, hdc
.ELSEIF uMsg == WM_CREATE
	invoke CreatePen, PS_DASH, 2, 000000h
	mov hPen, eax
		invoke CreateSolidBrush, 0000FFh
		mov hBrush, eax
		cmp act, 1
		je OUTT
		call StartXY				; khoi tao toa do ban dau cho ellipse
		inc act
		OUTT:
		invoke SetTimer, hwnd, 1, 10, addr TimerProc	; Dat Timer id = 1, 10ms, ham callback la TimerProc

.ELSE
	invoke DefWindowProc, hwnd, uMsg, wParam, lParam	; thuc hien nhu mac dinh
.ENDIF
ret
WndProc endp

; CheckEllipse dung trong xu ly WM_PAINT va WM_TIMER
CheckEllipse proc left:DWORD, top:DWORD, right:DWORD, bottom:DWORD
xor eax, eax
xor ebx, ebx
mov eax, left				; eax = canh trai cua so
mov ebx, topleft.x			; ebx = canh trai qua bong
cmp eax, ebx
jl L1						; neu canh trai qua bong > cua so thi duoc di tiep
							; neu canh trai qua bóng < cua so, can phai bat lai	
cmp [Random], 2				; if southwest, become southeast
jnz Ran0
mov [Random], 1
Ran0:
cmp [Random], 3				; if northwest, becom northeast
jnz Ran1
mov [Random], 0
Ran1:
L1:
xor eax, eax
xor ebx, ebx
mov eax, bottom				; eax = day cua so
mov ebx, bottomright.y		; ebx = day qua bong
cmp eax, ebx
jg L2						; day cua so > day bong, co the di tiep
cmp [Random], 1				; neu day cua so < hon day bong, can phai bat lai
jnz Ran2
mov [Random], 0				; if southeast, become northeast
Ran2:
cmp [Random], 2
jnz Ran3
mov [Random], 3				; if southwest, become northwest
Ran3:
L2:
xor eax, eax
xor ebx, ebx
mov eax, right				; eax = canh phai cua so
mov ebx, bottomright.x		; ebx = canh phai qua bong
cmp eax, ebx
jg L3						; neu canh phai cua so > canh phai qua bóng, ok. Luu y bot = max
cmp [Random], 0				; neu < hon
jnz Ran4
mov [Random], 3				;northeast become northwest
Ran4:
cmp [Random], 1
jnz Ran5
mov [Random], 2				; southeast becom south west
Ran5:
L3:
xor eax, eax
xor ebx, ebx
mov eax, top				; eax = canh tren cua so
mov ebx, topleft.y			; ebx = canh tren cua qua bong
cmp eax, ebx
jl L4						; neu canh tren cua so < canh tren qua bong, ok. Luu y top = 0
cmp [Random], 0
jnz Ran6
mov [Random], 1				; northeast become southeast
Ran6:
cmp [Random], 3
jnz Ran7
mov [Random], 2				; northwest become southwest
Ran7:
L4:

ret
CheckEllipse endp

WinMain proc hInstance:HINSTANCE, hPrevInst: HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
; LOCAL la chi thi directive, bien local duoc luu trong stack
LOCAL hwnd:HWND

mov wnd.cbSize, SIZEOF WNDCLASSEX
mov wnd.style, CS_HREDRAW or CS_VREDRAW
mov wnd.lpfnWndProc, offset WndProc			;WndProc la proceudre xu ly message tu su kien.
mov wnd.cbClsExtra, 0
mov wnd.cbWndExtra, 0
push Hinstance								; wnd.hInstance = Hinstance
pop wnd.hInstance							;
invoke LoadIcon, NULL, IDC_ARROW			; lay icon
mov wnd.hIcon, eax
mov wnd.hIconSm, eax
invoke LoadCursor, NULL, IDC_WAIT			; lay cursor mac dinh
mov wnd.hCursor, 0
mov wnd.hbrBackground, COLOR_WINDOW+0
mov wnd.lpszMenuName, 0
mov wnd.lpszClassName, offset ClassName

invoke RegisterClassEx, addr wnd			; sau khi truyen tham so cho wnd, khoi tao window class 
invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName, addr Namee, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 1130, 600, 0, 0, Hinstance, 0
mov hwnd, eax
invoke ShowWindow, hwnd, SW_SHOW			; ShowWindow hien thi cua so
invoke UpdateWindow, hwnd					; UpdateWindow hien thi noi dung cua so

IFNL:
invoke GetMessage, ADDR msg, 0, 0, 0
cmp eax, 0
jz EXIT
invoke TranslateMessage, ADDR msg
invoke DispatchMessage, ADDR msg
jmp IFNL
EXIT:
ret
WinMain endp

StartXY proc					; duoc goi tai WM_Create cua WndProc de khoi tao toa do Ellipse
invoke GetLocalTime, addr STIME		; Random toa do truc x
mov ax, STIME.wMilliseconds
mov ecx, 1000
xor edx, edx
div cx
mov topleft.x, edx
add dx, SOFB
mov bottomright.x, edx

invoke GetLocalTime, addr STIME		; Random toa do truc y
mov ax, STIME.wMilliseconds
mov ecx, 541
xor edx, edx
div cx
mov topleft.y, edx
add dx, SOFB
mov bottomright.y, edx

xor eax, eax						; Random 1 trong 4 huong di chuyen
invoke GetLocalTime, addr STIME
mov ax, STIME.wMilliseconds
mov ecx, 4
div cl
mov byte ptr [Random], ah			; Bien random chua huong di chuyen

ret
StartXY endp

; move Ellipse ve lai Ellipse sau khi kiem tra vi tri Ellipse
moveEllipse proc
mov eax, dword ptr [vectorX]		; toc do di chuyen theo X
mov ecx, dword ptr [vectorY]		; toc do di chuyen theo Y

cmp [Random], 0
jnz Case1; 45 do
add topleft.x, eax				; di northeast, x tang, y giam
sub topleft.y, ecx
add bottomright.x, eax
sub bottomright.y, ecx
Case1:
cmp [Random], 1
jnz Case2
	add topleft.x, eax			; di southeast, x tang, y tang
	add topleft.y, ecx
	add bottomright.x, eax
	add bottomright.y, ecx
Case2:
cmp [Random],2
jnz Case3
	sub topleft.x, eax			; di southwest, x giam, y tang
	add topleft.y, ecx
	sub bottomright.x, eax
	add bottomright.y, ecx
Case3:
cmp [Random], 3
jnz Case4
	sub topleft.x, eax			; di northwest, x giam, y giam
	sub topleft.y, ecx
	sub bottomright.x, eax
	sub bottomright.y, ecx
Case4:
ret
moveEllipse endp

main proc
invoke GetModuleHandle, 0
mov Hinstance, eax
invoke GetCommandLine
mov CommandLine, eax
invoke WinMain, Hinstance, 0, CommandLine, SW_SHOW
invoke ExitProcess, 0
main endp

end main  ; ket thuc chuong trinh

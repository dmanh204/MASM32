.386	; khai bao kien truc vi xu ly tu 32 bit
.model flat, stdcall	; khoi tao mo hinh bo nho chuong trinh, xac dinh kich thuoc code, con tro du lieu
option casemap :none	; turn off phan biet chu hoa va thuong

include \masm32\include\windows.inc		; de lap trinh Windows API
	; giup tao cua so, hien thi hop thoai, lam viec voi GUI
	; Cac ham MessageBox, CreateWindow
include \masm32\include\kernel32.inc	; khai bao ham cung cap chuc nang quan ly mem, process, thread, file
	; giup thoat chuong trinh, lay thong tin he thong, thao tac voi file va memory.
	; Cac ham ExitProcess, GetModuleHandle, HeapAlloc, CreateFile
include \masm32\include\msvcrt.inc		; cung cap khai bao ham C Runtime Library, gom cac ham C xu ly In/Out, xu ly chuoi, toan hoc
	; giup su dung cac ham C quen thuoc printf, scanf, strlen, memcpy
include \masm32\include\comdlg32.inc	; khai bao ham cung cap common dialogs cua windows nhu mo tep, luu tep, chon mau, chon font.
	; can khi hien thi cac hop thoai giao dien de nguoi dung tuong tac
	; GetOpenFileName, GetSaveFileName, ChooseColor.
; Them cac thu vien chua ma thuc thi
includelib \masm32\lib\msvcrt.lib		; Lien ket program va msvcrt.dll thong qua .lib
	; linker se su dung msvcrt.lib de tim ma thuc thi trong msvcrt.dll
includelib \masm32\lib\kernel32.lib		; Lien ket voi kernel32.dll, cung cap ma thuc thi cho cac ham khai bao trong kernel32.inc
includelib \masm32\lib\comdlg32.lib		; Lien ket voi comdlg32.dll, cung cap ma thuc thi cho cac ham khai bao trong comdlg32.inc

.data
MAPPEDOK	db 10, 13, "[+] The file is mapped in memory.", 10, 13, 0
						; ERROR

OPENFAIL	db 10, 13, "[!] Failed to open file.", 0
FAILMAPPING db 10, 13, "[!] Failed to map file.", 0
FAILMAPVIEW db 10, 13, "[!] Failed to map view of file.", 0
NOPE		db 10, 13, "[!] File is not a portable executable. 'MZ' Signature not found.", 0

						; HEADER

DOSHeader	db "[+] DOS Header", 10, 13, 10, 13, 0
PEHeader	db 10, 13, 10, 13, "[+] PE Header", 10, 13, 10, 13, 0
OptHeader	db 10, 13, 10, 13, "[+] Optional Header", 10, 13, 10, 13, 0
DataDir		db 10, 13, 10, 13, "[+] Data Directories", 10, 13, 10, 13, 0
Sectionstr	db 10, 13, 10, 13, "[+] Sections", 10, 13, 10, 13, 0

						; IMAGE_DOS_HEADER

e_magic		db 9, "e_magic: 0x", 0		; magic number 'MZ'
e_cblp		db 9, "e_cblp: 0x", 0		; so byte dung o trang cuoi
e_cp		db 9, "e_cb: 0x", 0			; count of page, so trang trong file
e_crlc		db 9, "e_crlc: 0x", 0		; kich thuoc checksum
e_cparhdr	db 9, "e_cparhdr: 0x", 0	; kich thuoc chuong trinh thuc thi
e_minalloc	db 9, "e_minalloc: 0x", 0	; so doan toi thieu trong bo nho
e_maxalloc	db 9, "e_maxalloc: 0x", 0	; so doan toi da trong bo bho
e_ss		db 9, "e_ss: 0x", 0			; gia tri ban dau cua thanh ghi stack segment
e_sp		db 9, "e_sp: 0x", 0			; gia tri ban dau cua thanh ghi stack pointer
e_csum		db 9, "e_csum: 0x", 0		; gia tri cua checksum
e_ip		db 9, "e_ip: 0x", 0			; gia tri ban dau cua thanh ghi instruction pointer
e_cs		db 9, "e_cs: 0x", 0			; gia tri ban day cua thanh ghi code segment
e_lfarlc	db 9, "e_lfarlc: 0x", 0		; dia chi relocation table
e_ovno		db 9, "e_ovno: 0x", 0		; so lop phu cua phan hien tai
e_res		db 9, "e_res: 0x", 0		; du tru res[4]
e_oemid		db 9, "e_oemid: 0x", 0		; khai bao Original Equipment Manufacturer
e_oeminfo	db 9, "e_oeminfo: 0x", 0	; thong tin Original Equipment Manufacturer
e_res2		db 9, "e_res2: 0x", 0		; du tru res2[10]
e_lfanew	db 9, "e_lfanew: 0x", 0		; offset toi NT Header (PE Header)

						; IMAGE_NT_HEADER
Signature	db 9, "Signature: 0x", 0	; Chu ky cua PE file, 4 byte

; IMAGE_FILE_HEADER (File Header)
Machine				db 9, "Machine: 0x", 0			; Kien truc cua may x86, x64, ARM
NumberOfSections	db 9, "NumberOfSections: 0x", 0	; So luong section
TimeDateStamp		db 9, "TimeDateStamp: 0x", 0	; 
PointerToSymbolTable db 9, "PointerToSymbolTable: 0x", 0	;
NumberOfSymbols		db 9, "NumberOfSymbols: 0x", 0	;
SizeOfOptionalHeader db 9, "SizeOfOptionalHeader: 0x", 0	; Kich thuoc phan optional cua header
Characteristics		db 9, "Characteristics: 0x", 0	; Loai file dll hay exe

; IMAGE_OPTIONAL_HEADER (Optional Header)
; Thiet yeu de thuc thi file PE

Magic				db 9, "Magic: 0x", 0			; chua gia tri xac dinh file 32/64 bit
MajorLinkerVersion	db 9, "MajorLinkerVersion: 0x", 0	;
MinorLinkerVersion	db 9, "MinorLinkerVersion: 0x", 0
SizeOfCode			db 9, "SizeOfCode: 0x", 0
SizeOfInitializedData db 9, "SizeOfInitializedData: 0x", 0
SizeOfUninitializedData db 9, "SizeOfUninitializedData: 0x", 0
AddressOfEntryPoint db 9, "AddressOfEntryPoint: 0x", 0	; Cho Windows loader biet noi thuc thi dau tien
BaseOfCode			db 9, "BaseOfCode: 0x", 0		; Dia chi ao tuong doi cua phan code
BaseOfData			db 9, "BaseOfData: 0x", 0		; Dia chi ao tuong doi cua phan data
ImageBase			db 9, "ImageBase: 0x", 0
SectionAlignment	db 9, "SectionAlignment: 0x", 0
FileAlignment		db 9, "FileAlignment: 0x", 0
MajorOperatingSystemVersion	db 9, "MajorOperationSystemVersion: 0x", 0
MinorOperatingSystemVersion	db 9, "MinorOperatingSystemVersion: 0x", 0
MajorImageVersion	db 9, "MajorImageVersion: 0x", 0
MinorImageVersion	db 9, "MinorImageVersion: 0x", 0
MajorSubsystemVersion	db 9, "MajorSubsystemVersion: 0x", 0
MinorSubsystemVersion	db 9, "MinorSubsystemVersion: 0x", 0
Win32VersionValue	db 9, "Win32VersionValue: 0x", 0
SizeOfImage			db 9, "SizeOfImage: 0x", 0
SizeOfHeaders		db 9, "SizeOfHeaders: 0x", 0
CheckSum			db 9, "CheckSum: 0x", 0
Subsystem			db 9, "Subsystem: 0x", 0
DllCharacteristics	db 9, "DllCharacteristics: 0x", 0
SizeOfStackReserve	db 9, "SizeOfStackReserve: 0x", 0
SizeOfStackCommit	db 9, "SizeOfStackCommit: 0x", 0
SizeOfHeapReserve	db 9, "SizeOfHeapReserve: 0x", 0
SizeOfHeapCommit	db 9, "SizeOfHeapCommit: 0x", 0
LoaderFlags			db 9, "LoaderFlags: 0x", 0
NumberOfRvaAndSizes	db 9, "NumberOfRvaAndSizes: 0x", 0

; IMAGE_DATA_DIRECTORY
; nam o cuoi IMAGE_OPTIONAL_HEADER

ExportTableRVA	db	9, "ExportTableRVA: 0x", 0
ExportTableSize	db	9, "ExportTableSize: 0x", 0

ImportTableRVA	db	9, "ImportTableRVA: 0x", 0
ImportTableSize	db	9, "ImportTableSize: 0x", 0

ResourceRVA		db	9, "ResourceRVA: 0x", 0
ResourceSize	db	9, "ResourceSize: 0x", 0

ExceptionRVA	db	9, "ExceptionRVA: 0x", 0
ExceptionSize	db	9, "ExceptionSize: 0x", 0

SecurityRVA		db	9, "SecurityRVA: 0x", 0
SecuritySize	db	9, "SecuritySize: 0x", 0

RelocationRVA	db	9, "RelocationRVA: 0x", 0
RelocationSize	db	9, "RelocationSize: 0x", 0

DebugRVA		db	9, "DebugRVA: 0x", 0
DebugSize		db	9, "DebugSize: 0x", 0

CopyrightRVA	db	9, "CopyrightRVA: 0x", 0
CopyrightSize	db	9, "CopyrightSize: 0x", 0

GlobalptrRVA	db	9, "GlobalptrRVA: 0x", 0
GlobalptrSize	db	9, "GlobalptrSize: 0x", 0

TlsTableRVA		db	9, "TlsTableRVA: 0x", 0
TlsTableSize	db	9, "TlsTableSize: 0x", 0

LoadConfigRVA	db	9, "LoadConfigRVA: 0x", 0
LoadConfigSize	db	9, "LoadConfigSize: 0x", 0

BoundImportRVA	db	9, "BoundImportRVA: 0x", 0
BoundImportSize	db	9, "BoundImportSize: 0x", 0

IATRVA			db	9, "IATRVA: 0x", 0
IATSize			db	9, "IATSize: 0x", 0

DelayImportRVA	db	9, "DelayImportRVA: 0x", 0
DelayImportSize	db	9, "DelayImportSize: 0x", 0

COMRVA			db	9, "COMRVA: 0x", 0
COMSize			db	9, "COMSize: 0x", 0

ReservedRVA		db	9, "ReservedRVA: 0x", 0
ReservedSize	db	9, "ReservedSize: 0x", 0

						; PE Section
Namee db 9, "Name: ", 0
VirtualSize db 9, "Virtual Size: 0x", 0
RVA db 9, "RVA: 0x", 0
SizeOfRawData db 9, "Size Of Raw Data: 0x", 0
PointerToRawData db 9, "Pointer to Raw Data: 0x", 0
PointerToRelocations db 9, "Pointer to Relocations: 0x", 0
PointerToLineNumbers db 9, "Pointer to Line Numbers: 0x", 0
NumberOfRelocations db 9, "Number of Relocations: 0x", 0
NumberOfLineNumbers db 9, "Number of Line Numbers: 0x", 0
Characteristicss db 9, "Charactertistics: 0x", 0

newlinee db 0ah
filename db 260 dup(0)		; 260 la kich thuoc toi da cua duong dan tep trong Windows
ofn OPENFILENAME <>			; struct cau hinh, quan ly hop thoai chon tep.
; struct nay chua duoc khoi tao (<>). 
; struct se duoc dien thong tin nhu con tro tro toi filename, filterString,...
filterString		db "Exe File (*.exe)", 0, "*.exe", 0
					db "Dll File (*.dll)", 0, "*.dll", 0
					db "All Files", 0, "*.*", 0
; filterString dung dinh nghia bo loc cho hop thoai chon tep.
; moi bo loc gom phan ten va phan mo rong.

handleCF HANDLE 0
handleMP HANDLE 0
Sizee db 0
filept dd 0
bytee db 2
wordd db 4
dwordd db 8
HandleRead HANDLE 0
HandleWrite HANDLE 0
realout dd 0
r1 db 8 dup(0)
r2 db 8 dup(0)

.data?
 sections db ?

.code
; procedure 'strlen1' duoc dung de dem do dai 1 string
; offset cua string do da duoc push len stack truoc khi goi procedure
; Ket qua duoc luu vao bien Sizee
strlen1 proc
pushad		; day toan bo thanh ghi 32 bit len stack eax, ebx, ecx, edx, esi, edi, ebp, esp
push ebp
mov ebp, esp	; luu dia chi stack hien tai vao ebp

mov eax, [ebp + 40]				; offset cua string dang o tren stack
xor ecx, ecx
L1:
mov bl, BYTE PTR [eax + ecx]	; eax[ecx]
inc ecx
cmp bl, 0h						; eax[ecx] == NULL?
jnz L1
	; yes
dec ecx
mov eax, offset Sizee
mov BYTE PTR [eax], cl

mov esp, ebp
pop ebp
popad
ret
strlen1 endp

format proc
; Truoc khi goi format, day len stack 1 gia tri 1, 2, 4 bieu thi so byte can doc
; va truyen vao ecx dia chi cua truong can doc.
; Khoi dong
pushad			; push 8 register
push ebp		; push ebp lan nua
mov ebp, esp	; luu esp vao ebp

mov eax, [ebp + 40]		; truy cap vao gia tri duoc day len stack truoc khi goi 'format'
mov esi, offset Sizee	; esi =  offset(Sizee)
mov BYTE PTR [esi], al	
mov eax, offset r1		; r1 duoc dung lam mang chua gia tri doc ra tu cac truong
cmp BYTE PTR [esi], 2	; giatri = 2?
jz WORDD	; neu = 2
cmp BYTE PTR [esi], 4
jz DWORDD	; neu = 4
mov BYTE PTR [eax], cl	; neu bang 1
jmp CONT

WORDD:
mov WORD PTR [eax], cx
jmp CONT

DWORDD:
mov DWORD PTR [eax], ecx

CONT:
push offset r1
call hextoa			; chuyen so thanh string de in ra
; Ket thuc
mov esp, ebp
pop ebp
popad
ret
format endp

hextoa proc
; proc  nay lay 1 gia tri, chia co so 16 de co duoc bieu dien hex, day len stack
; lay tu stack ra va thuc hien cong 30h voi gia tri tu 0-9, 37h voi a-f
; luu chuoi vao r2
; in ra man hinh va thoat.
; Khoi dong
pushad
push ebp
mov ebp, esp

mov ebx, [ebp + 40]			; lay tham so truyen vao tu stack
xor ecx, ecx
movzx ecx, BYTE PTR [esi]
xor esi, esi
add esi, 10h

mov eax, 57h
push eax
xor edi, edi

L3:
cmp edi, 2
jz L4
xor eax, eax
push eax

L4:
xor edi, edi
xor eax, eax
cmp ecx, 0
jz L2			; L2 neu eax = 0
dec ecx
mov al, BYTE PTR [ebx + ecx]
cmp al, 0
jnz	LOO			; [ebx + ecx] != 0
push eax
push eax
jmp L4			; quay lai L4

LOO:
xor edx, edx
idiv esi
push edx
inc edi
cmp al, 0
jz L3
jmp LOO

L2:
xor ebx, ebx
xor edx, edx
mov ebx, offset r2
INN:
pop ecx
cmp cl, 57h
jz OUTT
mov BYTE PTR [ebx + edx], cl
inc edx
jmp INN

OUTT:
xor ecx, ecx
mov esi, offset Sizee
movzx ecx, BYTE PTR [esi]
add ecx, ecx
mov BYTE PTR [esi], cl
JUM:
cmp ecx, 0
jz EXITT
dec ecx
cmp BYTE PTR [ebx + ecx], 0ah
jl Lu
add BYTE PTR [ebx + ecx], 37h
jmp JUM
Lu:
add BYTE PTR [ebx + ecx], 30h
jmp JUM
EXITT:
push offset r2
call print

mov esp, ebp
pop ebp
popad
ret
hextoa endp

print proc
pushad
push ebp
mov ebp, esp
mov ebx, [ebp + 40]
invoke WriteConsole, HandleWrite, ebx, Sizee, ADDR realout, 0	; ebx = offset string duoc truyen len stack
invoke WriteConsole, HandleWrite, ADDR newlinee, 1, ADDR realout, 0	; xuong dong

mov esp, ebp
pop ebp
popad
ret
print endp

printstr proc
pushad
push ebp
mov ebp, esp
mov ebx, [ebp + 40]
invoke WriteConsole, HandleWrite, ebx, Sizee, ADDR realout, 0
mov esp, ebp
pop ebp
popad
ret
printstr endp

main proc
invoke GetStdHandle, STD_INPUT_HANDLE
mov HandleRead, eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov HandleWrite, eax

mov ofn.lStructSize, sizeof OPENFILENAME
 mov ofn.hwndOwner, NULL
 mov ofn.lpstrFilter, offset filterString ; Filter for files types
 mov ofn.lpstrFile, offset filename
 mov ofn.nMaxFile, sizeof filename
 mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
 ; Goi hop thoai chon file
 invoke GetOpenFileName, ADDR ofn
 ; Sau khi nguwoi dung chon tep, path nam trong 'filename'

; Goi ham CreateFile tu Windows API, dung de open/create file
; filename - duong dan toi tep
; GENERIC_READ - Quyen truy cap read-only
; FILE_SHARE_READ - Che do chia se, cho phep cac process khac cung doc file
; 0 - Khong dung cau truc bao mat
; OPEN_EXISTING - chi mo tep da ton tai
; FILE_ATTRIBUTE_NORMAL - thuoc tinh file la normal, khong phai hidden, system file vv
; 0 - Handle mau
invoke CreateFile, ADDR filename, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
cmp eax, INVALID_HANDLE_VALUE		
je FailOpen
mov handleCF, eax			; handle cua file duoc luu trong eax sau invoke

; CreateFileMapping tao 1 doi tuong anh xa noi dung file vao bo nho
; handle cua tep da mo se duoc truyen vao
invoke CreateFileMapping, handleCF, NULL, PAGE_READONLY, 0, 0, NULL
cmp eax, NULL
je FailMapping
mov handleMP, eax

; MapViewOfFile anh xa noi dung file vao bo nho cua process qua doi tuong
; handle cua doi tuong duoc truyen vao
invoke MapViewOfFile, handleMP, FILE_MAP_READ, 0, 0, 0
cmp eax, NULL
je FailMapview
mov filept, eax			; Sau khi anh xa file vao bo nho, luu dia chi bat dau vao 'filept'

; In thong bao da anh xa thanh cong.
push offset MAPPEDOK
call strlen1
push offset MAPPEDOK
call printstr

mov edi, filept
; 'assume' la mot chi thi (directive), khong tao ra machine code, ma chi thong bao cho assembler thanh ghi edi
; se duoc xem nhu con tro den struct IMAGE_DOS_HEADER
; 'IMAGE_DOS_HEADER' la struct duoc dinh nghia trong WindowsAPI (Windows.inc)
; instruction duoi day cho assembler hieu rang khi truy cap cac truong cua edi, no se tham chieu den cac offset tuong ung
; trong cau truc IMAGE_DOS_HEADER
assume edi: ptr IMAGE_DOS_HEADER
; So sanh truong e_magic cua edi voi gia tri standard trong struct.
cmp [edi].e_magic, IMAGE_DOS_SIGNATURE
jne LACKMZ

push offset DOSHeader
call strlen1
push offset DOSHeader
call printstr

push offset e_magic
call strlen1
push offset e_magic
call printstr
movzx ecx, [edi].e_magic	; move with zero extension
push 2
call format

push offset e_cblp
call strlen1
push offset e_cblp
call printstr
movzx ecx, [edi].e_cblp
push 2	; doc 2 byte
call format

push offset e_cp
call strlen1
push offset e_cp
call printstr
movzx ecx, [edi].e_cp
push 2
call format

push offset e_crlc
call strlen1
push offset e_crlc
call printstr
movzx ecx, [edi].e_crlc
push 2
call format

push offset e_cparhdr
call strlen1
push offset e_cparhdr
call printstr
movzx ecx, [edi].e_cparhdr
push 2
call format

push offset e_minalloc
call strlen1
push offset e_minalloc
call printstr
movzx ecx, [edi].e_minalloc
push 2
call format

push offset e_maxalloc
call strlen1
push offset e_maxalloc
call printstr
movzx ecx, [edi].e_maxalloc
push 2
call format

push offset e_ss
call strlen1
push offset e_ss
call printstr
movzx ecx, [edi].e_ss
push 2
call format

push offset e_sp
call strlen1
push offset e_sp
call printstr
movzx ecx, [edi].e_sp
push 2
call format

push offset e_csum
call strlen1
push offset e_csum
call printstr
movzx ecx, [edi].e_csum
push 2
call format

push offset e_ip
call strlen1
push offset e_ip
call printstr
movzx ecx, [edi].e_ip
push 2
call format

push offset e_cs
call strlen1
push offset e_cs
call printstr
movzx  ecx, [edi].e_cs
push 2
call format

push offset e_lfarlc
call strlen1
push offset e_lfarlc
call printstr
movzx ecx, [edi].e_lfarlc
push 2
call format

push offset e_ovno
call strlen1
push offset e_ovno
call printstr
movzx ecx, [edi].e_ovno
push 2
call format

push offset e_res
call strlen1
push offset e_res
call printstr
movzx ecx, [edi].e_res
push 2
call format

push offset e_oemid
call strlen1
push offset e_oemid
call printstr
movzx ecx, [edi].e_oemid
push 2
call format

push offset e_oeminfo
call strlen1
push offset e_oeminfo
call printstr
movzx ecx, [edi].e_oeminfo
push 2
call format

push offset e_res2
call strlen1
push offset e_res2
call printstr
movzx ecx, [edi].e_res2
push 2
call format

push offset e_lfanew
call strlen1
push offset e_lfanew
call printstr
mov ecx, [edi].e_lfanew
push 4			; doc 4 byte
call format

; e_lfanew cho biet khoang cach tu dos header toi pe header
add edi, ecx	; tinh ra dia chi pe header
assume edi: ptr IMAGE_NT_HEADERS	; dat edi lam con tro vung nho
cmp [edi].Signature, IMAGE_NT_SIGNATURE
jne Exitt

push offset PEHeader
call strlen1
push offset PEHeader
call printstr
; Hien thi phan PE header

push offset Signature
call strlen1
push offset Signature
call printstr
mov ecx, [edi].Signature
push 4
call format

add edi, 4	; Signature la Dword
assume edi: ptr IMAGE_FILE_HEADER

push offset Machine
call strlen1
push offset Machine
call printstr
movzx ecx, [edi].Machine
push 2
call format

push offset NumberOfSections
call strlen1
push offset NumberOfSections
call printstr
movzx ecx, [edi].NumberOfSections
mov eax, offset sections		; 2 dong nay de luu so Section vao bien Sections
mov BYTE PTR [eax], cl			;
push 2
call format

push offset TimeDateStamp
call strlen1
push offset TimeDateStamp
call printstr
mov ecx, [edi].TimeDateStamp
push 4
call format

push offset PointerToSymbolTable
call strlen1
push offset PointerToSymbolTable
call printstr
mov ecx, [edi].PointerToSymbolTable
push 4
call format

push offset NumberOfSymbols
call strlen1
push offset NumberOfSymbols
call printstr
mov ecx, [edi].NumberOfSymbols
push 4
call format

push offset SizeOfOptionalHeader
call strlen1
push offset SizeOfOptionalHeader
call printstr
movzx ecx, [edi].SizeOfOptionalHeader
push 2
call format

push offset Characteristics
call strlen1
push offset Characteristics
call printstr
movzx ecx, [edi].Characteristics
push 2
call format

add edi, 14h	; Kich thuoc cua IMAGE_FILE_HEADER
assume edi: ptr IMAGE_OPTIONAL_HEADER

push offset OptHeader
call strlen1
push offset OptHeader
call printstr

push offset Magic
call strlen1
push offset Magic
call printstr
movzx ecx, [edi].Magic
push 2
call format

push offset MajorLinkerVersion
call strlen1
push offset MajorLinkerVersion
call printstr
movzx ecx, [edi].MajorLinkerVersion
push 1
call format

push offset MinorLinkerVersion
call strlen1
push offset MinorLinkerVersion
call printstr
movzx ecx, [edi].MinorLinkerVersion
push 1
call format

push offset SizeOfCode
call strlen1
push offset SizeOfCode
call printstr
mov ecx, [edi].SizeOfCode
push 4
call format

push offset SizeOfInitializedData
call strlen1
push offset SizeOfInitializedData
call printstr
mov ecx, [edi].SizeOfInitializedData
push 4
call format

push offset SizeOfUninitializedData
call strlen1
push offset SizeOfUninitializedData
call printstr
mov ecx, [edi].SizeOfUninitializedData
push 4
call format

push offset AddressOfEntryPoint
call strlen1
push offset AddressOfEntryPoint
call printstr
mov ecx, [edi].AddressOfEntryPoint
push 4
call format

push offset BaseOfCode
call strlen1
push offset BaseOfCode
call printstr
mov ecx, [edi].BaseOfCode
push 4
call format

push offset BaseOfData
call strlen1
push offset BaseOfData
call printstr
mov ecx, [edi].BaseOfData
push 4
call format

push offset ImageBase
call strlen1
push offset ImageBase
call printstr
mov ecx, [edi].ImageBase
push 4
call format

push offset SectionAlignment
call strlen1
push offset SectionAlignment
call printstr
mov ecx, [edi].SectionAlignment
push 4
call format

push offset FileAlignment
call strlen1
push offset FileAlignment
call printstr
mov ecx, [edi].FileAlignment
push 4
call format

push offset MajorOperatingSystemVersion
call strlen1
push offset MajorOperatingSystemVersion
call printstr
movzx ecx, [edi].MajorOperatingSystemVersion
push 2
call format

push offset MinorOperatingSystemVersion
call strlen1
push offset MinorOperatingSystemVersion
call printstr
movzx ecx, [edi].MinorOperatingSystemVersion
push 2
call format

push offset MajorImageVersion
call strlen1
push offset MajorImageVersion
call printstr
movzx ecx, [edi].MajorImageVersion
push 2
call format

push offset MinorImageVersion
call strlen1
push offset MinorImageVersion
call printstr
movzx ecx, [edi].MinorImageVersion
push 2
call format

push offset MajorSubsystemVersion
call strlen1
push offset MajorSubsystemVersion
call printstr
movzx ecx, [edi].MajorSubsystemVersion
push 2
call format

push offset MinorSubsystemVersion
call strlen1
push offset MinorSubsystemVersion
call printstr
movzx ecx, [edi].MinorSubsystemVersion
push 2
call format

push offset Win32VersionValue
call strlen1
push offset Win32VersionValue
call printstr
mov ecx, [edi].Win32VersionValue
push 4
call format

push offset SizeOfImage
call strlen1
push offset SizeOfImage
call printstr
mov ecx, [edi].SizeOfImage
push 4
call format

push offset SizeOfHeaders
call strlen1
push offset SizeOfHeaders
call printstr
mov ecx, [edi].SizeOfHeaders
push 4
call format

push offset CheckSum
call strlen1
push offset CheckSum
call printstr
mov ecx, [edi].CheckSum
push 4
call format

push offset Subsystem
call strlen1
push offset Subsystem
call printstr
movzx ecx, [edi].Subsystem
push 2
call format

push offset DllCharacteristics
call strlen1
push offset DllCharacteristics
call printstr
movzx ecx, [edi].DllCharacteristics
push 2
call format

push offset SizeOfStackReserve
call strlen1
push offset SizeOfStackReserve
call printstr
mov ecx, [edi].SizeOfStackReserve
push 4
call format

push offset SizeOfStackCommit
call strlen1
push offset SizeOfStackCommit
call printstr
mov ecx, [edi].SizeOfStackCommit
push 4
call format

push offset SizeOfHeapReserve
call strlen1
push offset SizeOfHeapReserve
call printstr
mov ecx, [edi].SizeOfHeapReserve
push 4
call format

push offset SizeOfHeapCommit
call strlen1
push offset SizeOfHeapCommit
call printstr
mov ecx, [edi].SizeOfHeapCommit
push 4
call format

push offset LoaderFlags
call strlen1
push offset LoaderFlags
call printstr
mov ecx, [edi].LoaderFlags
push 4
call format

push offset NumberOfRvaAndSizes
call strlen1
push offset NumberOfRvaAndSizes
call printstr
mov ecx, [edi].NumberOfRvaAndSizes
push 4
call format

; Data Directory - nam cuoi Optional Header
push offset DataDir
call strlen1
push offset DataDir
call printstr

push offset ExportTableRVA
call strlen1
push offset ExportTableRVA
call printstr
add edi, 60h			; kich thuoc cua cac truong dung truoc data directory trong optional header
	; Do khong co struct mau de bieu dien, ta truy cap truc tiep vao bo nho
mov ecx, dword ptr [edi]
push 4
call format

push offset ExportTableSize
call strlen1
push offset ExportTableSize
call printstr
mov ecx, dword ptr [edi + 4h]
push 4
call format

push offset ImportTableRVA
call strlen1
push offset ImportTableRVA
call printstr
mov ecx, dword ptr [edi + 8h]
push 4
call format

push offset ImportTableSize
call strlen1
push offset ImportTableSize
call printstr
mov ecx, dword ptr [edi + 0Ch]
push 4
call format

push offset ResourceRVA
call strlen1
push offset ResourceRVA
call printstr
mov ecx, dword ptr [edi + 10h]
push 4
call format

push offset ResourceSize
call strlen1
push offset ResourceSize
call printstr
mov ecx, dword ptr [edi + 14h]
push 4
call format

push offset ExceptionRVA
call strlen1
push offset ExceptionRVA
call printstr
mov ecx, dword ptr [edi + 18h]
push 4
call format

push offset ExceptionSize
call strlen1
push offset ExceptionSize
call printstr
mov ecx, dword ptr [edi + 1ch]
push 4
call format

push offset SecurityRVA
call strlen1
push offset SecurityRVA
call printstr
mov ecx, dword ptr [edi + 20h]
push 4
call format

push offset SecuritySize
call strlen1
push offset SecuritySize
call printstr
mov ecx, dword ptr [edi + 24h]
push 4
call format

push offset RelocationRVA
call strlen1
push offset RelocationRVA
call printstr
mov ecx, dword ptr [edi + 28h]
push 4
call format

push offset RelocationSize
call strlen1
push offset RelocationSize
call printstr
mov ecx, dword ptr [edi + 2ch]
push 4
call format

push offset DebugRVA
call strlen1
push offset DebugRVA
call printstr
mov ecx, dword ptr [edi + 30h]
push 4
call format

push offset DebugSize
call strlen1
push offset DebugSize
call printstr
mov ecx, dword ptr [edi + 34h]
push 4
call format

push offset CopyrightRVA
call strlen1
push offset CopyrightRVA
call printstr
mov ecx, dword ptr [edi + 38h]
push 4
call format

push offset CopyrightSize
call strlen1
push offset CopyrightSize
call printstr
mov ecx, dword ptr [edi + 3ch]
push 4
call format

push offset GlobalptrRVA
call strlen1
push offset GlobalptrRVA
call printstr
mov ecx, dword ptr [edi + 40h]
push 4
call format

push offset GlobalptrSize
call strlen1
push offset GlobalptrSize
call printstr
mov ecx, dword ptr [edi + 44h]
push 4
call format

push offset TlsTableRVA
call strlen1
push offset TlsTableRVA
call printstr
mov ecx, dword ptr [edi + 48h]
push 4
call format

push offset TlsTableSize
call strlen1
push offset TlsTableSize
call printstr
mov ecx, dword ptr [edi + 4ch]
push 4
call format

push offset LoadConfigRVA
call strlen1
push offset LoadConfigRVA
call printstr
mov ecx, dword ptr [edi + 50h]
push 4
call format

push offset LoadConfigSize
call strlen1
push offset LoadConfigSize
call printstr
mov ecx, dword ptr [edi + 54h]
push 4
call format

push offset BoundImportRVA
call strlen1
push offset BoundImportRVA
call printstr
mov ecx, dword ptr [edi + 58h]
push 4
call format

push offset BoundImportSize
call strlen1
push offset BoundImportSize
call printstr
mov ecx, dword ptr [edi + 5ch]
push 4
call format

push offset IATRVA
call strlen1
push offset IATRVA
call printstr
mov ecx, dword ptr [edi + 60h]
push 4
call format

push offset IATSize
call strlen1
push offset IATSize
call printstr
mov ecx, dword ptr [edi + 64h]
push 4
call format

push offset DelayImportRVA
call strlen1
push offset DelayImportRVA
call printstr
mov ecx, dword ptr [edi + 68h]
push 4
call format

push offset DelayImportSize
call strlen1
push offset DelayImportSize
call printstr
mov ecx, dword ptr [edi + 6ch]
push 4
call format

push offset COMRVA
call strlen1
push offset COMRVA
call printstr
mov ecx, dword ptr [edi + 70h]
push 4
call format

push offset COMSize
call strlen1
push offset COMSize
call printstr
mov ecx, dword ptr [edi + 74h]
push 4
call format

push offset ReservedRVA
call strlen1
push offset ReservedRVA
call printstr
mov ecx, dword ptr [edi + 78h]
push 4
call format

push offset ReservedSize
call strlen1
push offset ReservedSize
call printstr
mov ecx, dword ptr [edi + 7ch]
push 4
call format

sub edi , 60h
; IMAGE_SECTION_HEADER
add edi, sizeof IMAGE_OPTIONAL_HEADER
assume edi: ptr IMAGE_SECTION_HEADER

mov al, sections		; So section can hien thi
cmp al, 0
je lack

push offset Sectionstr
call strlen1
push offset Sectionstr
call printstr

restart:
cmp al, 0
jz success

push offset Namee
call strlen1
push offset Namee
call printstr
mov ecx, edi
mov ebx, offset Sizee
mov byte ptr [ebx], 8
push ecx
call print

push offset VirtualSize
call strlen1
push offset VirtualSize
call printstr
mov ecx, dword ptr [edi + 8]
push 4
call format

push offset RVA
call strlen1
push offset RVA
call printstr
mov ecx, dword ptr [edi + 0ch]
push 4
call format

push offset SizeOfRawData
call strlen1
push offset SizeOfRawData
call printstr
mov ecx, dword ptr [edi + 10h]
push 4
call format

push offset PointerToRawData
call strlen1
push offset PointerToRawData
call printstr
mov ecx, dword ptr [edi + 14h]
push 4
call format

push offset PointerToRelocations
call strlen1
push offset PointerToRelocations
call printstr
mov ecx, dword ptr [edi + 18h]
push 4
call format

push offset PointerToLineNumbers
call strlen1
push offset PointerToLineNumbers
call printstr
mov ecx, dword ptr [edi + 1ch]
push 4
call format

push offset NumberOfRelocations
call strlen1
push offset NumberOfRelocations
call printstr
mov ecx, dword ptr [edi + 20h]
push 2
call format

push offset NumberOfLineNumbers
call strlen1
push offset NumberOfLineNumbers
call printstr
mov ecx, dword ptr [edi + 22h]
push 2
call format

push offset Characteristicss
call strlen1
push offset Characteristicss
call printstr
mov ecx, dword ptr [edi + 24h]
push 4
call format

add edi, 28h
dec al
jmp restart

success:
jmp Exitt

lack:
jmp Exitt

FailOpen:
push offset OPENFAIL
call printstr
jmp Exitt

FailMapping:
push offset FAILMAPPING
call printstr
jmp Exitt

FailMapview:
push offset FAILMAPVIEW
call printstr
jmp Exitt

LACKMZ:
push offset NOPE
call printstr
jmp Exitt

Exitt:
main endp
end main
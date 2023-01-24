/*
Даны целые числа a0...a6.
Получить для x = 1, 3, 4 значения p(x+1) - p(x), где
p(y) = a6*y^6 + a5y^5 + ... + a0.
*/

include 'proc16.inc'

format mz
org 100h

/*---main---*/
/*---------------------------------------------------------------------------------------*/
; обнулю всё, что буду использовать (на всякий случай)
mov eax, 0
mov ebx, 0
mov ecx, 0
mov edx, 0
mov esi, 0
mov edi, 0

mov [n],7				; кол-во эл. массива

mov edi, array			; di = адрес первого эл. массива
stdcall array_filling	; заполнение массива
stdcall array_output	; вывод для проверки
stdcall print_endline

/*==== X1 ====*/
mov edi, x1				; в di адрес строки x1
stdcall print_str		; печать x1 в консоль
stdcall print_endline
mov di, array			; в di адрес массива (нужно в процедурах)
mov ax, 1				; значение x по заданию
stdcall main_proc		; p(y)

mov di, addition		; в di адрес строки addition
stdcall print_str		; печать
mov di, array
stdcall print_word_sdec	; вывод ax - p(x+1) - p(x)
stdcall print_endline

/*==== X3 ====*/		; далее всё то-же самое
mov edi, x3
stdcall print_str
stdcall print_endline
mov di, array
mov ax, 3				; значения x
stdcall main_proc		; p(y)

mov di, addition
stdcall print_str
mov di, array
stdcall print_word_sdec	; вывод ax - p(x+1) - p(x)
stdcall print_endline

/*==== X4 ====*/
mov edi, x4
stdcall print_str
stdcall print_endline
mov di, array
mov ax, 4				; значения x
stdcall main_proc		; p(y)

mov di, addition
stdcall print_str
mov di, array
stdcall print_word_sdec	; вывод ax - p(x+1) - p(x)
stdcall print_endline


xor di,di

; ожидание ввода
mov ah,01h
int 21h

; корректное завершение работы
mov ah,4ch
int 21h

/*---variables---*/
/*---------------------------------------------------------------------------------------*/
n db 0
buffer rb 256
array dw 100 dup(?) ; max 100 elements

input_elements db "input elements of array$"
x1 db "X = 1$"
x4 db "X = 4$"
x3 db "X = 3$"
addition db "Addition = $"
endline db 13,10,'$'
elements_intr db "elements introduced$"
output_elements db "output elements$"

/*---array---*/
/*---------------------------------------------------------------------------------------*/

; осн. процедура - p(x+1) - p(x)
; вход: di - адрес первого эллемента массива, ax - x
; выход: eax - результат
proc main_proc uses ebx

	mov bx, ax	; запоминаем, так как procedure меняет eax

	inc ax
	stdcall procedure	; p(x+1)
	push eax

	stdcall print_endline

	mov ax, bx
	stdcall procedure	; p(x)
	pop ebx

	sub ebx, eax		; p(x+1) - p(x)
	mov eax, ebx		; результат в eax (па томушта могу)

	ret
endp

; процедура p(y)
; вход: di - адрес первого эллемента массива, ax - y (параметр ф-и)
; выход: eax - результат
proc procedure uses ecx ebx edx edi
; сначала рассчёт a[i] * y^i, помещение этого говна в стек
	mov ch,0
	mov cl,[n]	; исп. для loop (счётчик)
	dec cl

	mov dx, [di]
	push edx	; помещ. arr[0] эл. в стек

	push eax
	mov eax, edx
	stdcall print_word_sdec	; вывод edx - текущего произведения (для проверки [0] эл)
	stdcall print_endline
	pop eax
	
	mov si, 1	; буду умножать на ax (для степени)

	cycle_mul:	; умножение эл. масс. на параметр в степени a[i] * y^i
		inc di	; перемещ. по масс. начинаем с [1]
		inc di	; inc дважды, так как массив 16 бит

		imul si, ax	; степень Y. Результат в si

		mov dx, [di]	; в dl эл. масс.
		imul dx, si		; a[i]	* y^i, результат в edx

		push eax
		mov eax, edx
		stdcall print_word_sdec	; вывод dx - текущего произведения (для проверки [1] - [6] эл)
		stdcall print_endline
		pop eax
		
		push edx	; в стеке будет 7 эл. a[i]	* y^i

	loop cycle_mul	; пока cx > 0 движемся по циклу

					; дале нужно сложить всё, что записали в стек
	mov ch,0
	mov cl,[n]	; исп. для loop
	dec cl

	pop eax	; последний эл. стека (чтоб было с чем складывать)
	cycle_sum:
		pop	edx
		add eax, edx
	loop cycle_sum
	ret
endp

; заполнение массива
; вход: di - адрес первого эллемента массива
; выход: заполненный массив. Доступ к массиву по его адресу (имени) либо через di
proc array_filling uses ax di cx bx
	push di
	mov di,input_elements
	stdcall print_str
	stdcall print_endline
	pop di
				;сх используется для цикла loop
	mov ch,0	;очистка старшей части сх
	mov cl,[n]	;запись в младшую часть кол-ва элементов массива
	mov bx,0	;очистка bx
filling_cycle:
	stdcall input_sdec_word	;ввод слова с консолт
	mov [di+bx],ax			;запись в элемент массива введенного чисда
	stdcall print_endline	;вывод конца строки
	inc bx					;увеличиваем bx чтобы идти дальше
	inc bx					;2 раза, тк массив из элементов по 16 бит
	loop filling_cycle

	mov di,elements_intr
	stdcall print_str
	stdcall print_endline
	ret
endp

; вывод массива
; вход: di - адрес первого эллемента массива
; выход: ничего не изменилось. Доступ к массиву по его адресу (имени) либо через di
proc array_output uses ax di cx bx
	push di
	mov di,output_elements
	stdcall print_str
	stdcall print_endline
	pop di
					;сх используется для цикла loop
	mov ch,0		;очистка старшей части сх
	mov cl,[n]		;запись в младшую часть кол-ва элементов массива
	mov bx,0		;очистка bx
output_cycle:
	mov ax,[di+bx]
	stdcall print_word_sdec	;выводд слова на консоль
	stdcall print_endline	;вывод конца строки
	inc bx					;увеличиваем bx чтобы идти дальше
	inc bx					;2 раза, тк массив из элементов по 16 бит
	loop output_cycle
	ret
endp


/*---input---*/
/*---------------------------------------------------------------------------------------*/
; Процедура ввода строки c консоли
; вход: AL - максимальная длина (с символом CR) (1-254)
; выход: AL - длина введённой строки (не считая символа CR)
; DX - адрес строки, заканчивающейся символом CR(0Dh)
proc input_str uses cx
	mov cx,ax				; Сохранение AX в CX
	mov ah,0Ah				; Функция DOS 0Ah - ввод строки в буфер
	mov [buffer],al			; Запись максимальной длины в первый байт буфера
	mov byte[buffer+1],0	; Обнуление второго байта (фактической длины)
	mov dx,buffer			; DX = aдрес буфера
	int 21h					; Обращение к функции DOS
	mov al,[buffer+1]		; AL = длина введённой строки
	add dx,2				; DX = адрес строки
	mov ah,ch				; Восстановление AH
	ret
endp

; Процедура преобразования десятичной строки в слово без знака
; вход: AL - длина строки
; DX - адрес строки, заканчивающейся символом CR(0Dh)
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
proc str_to_udec_word uses cx dx bx si di
	mov si,dx			; SI = адрес строки
	mov di,10			; DI = множитель 10 (основание системы счисления)
	movzx cx,al			; CX = счётчик цикла = длина строки
	jcxz studw_error	; Если длина = 0, возвращаем ошибку
	xor ax,ax			; AX = 0
	xor bx,bx			; BX = 0

studw_lp:
	mov bl,[si]			; Загрузка в BL очередного символа строки
	inc si
	cmp bl,'0'			; Если код символа меньше кода "0"
	jl studw_error		; Возвращаем ошибку
	cmp bl,'9'			; Если код символа больше кода "9"
	jg studw_error		; Возвращаем ошибку
	sub bl,'0'			; Преобразование символа-цифры в число
	mul di				; AX = AX * 10
	jc studw_error		; Если результат больше 16 бит - ошибка
	add ax,bx			; Прибавляем цифру
	jc studw_error		; Если переполнение - ошибка
	loop studw_lp		; Команда цикла
	jmp studw_exit		; Успешное завершение (здесь всегда CF = 0)

studw_error:
	xor ax,ax			; AX = 0
	stc					; CF = 1 (Возвращаем ошибку)

studw_exit:				; Завершение функции
	ret
endp

; Процедура преобразования десятичной строки в байт без знака
; вход: AL - длина строки
; DX - адрес строки, заканчивающейся символом CR(0Dh)
; выход: AL - байт (в случае ошибки AL = 0)
; CF = 1 - ошибка
proc str_to_udec_byte uses dx
	push ax
stdcall str_to_udec_word	; Преобразование строки в слово (без знака)
	jc studb_exit			; Если ошибка, то возвращаем ошибку
	test ah,ah				; Проверка старшего байта AX
	jz studb_exit			; Если 0, то выход из процедуры (здесь всегда CF = 0)
	xor al,al				; Обнуление AL
	stc						; CF = 1 (Возвращаем ошибку)
studb_exit:
	pop dx
	mov ah,dh				; Восстановление только старшей части AX
	ret
endp

; Процедура ввода слова с консоли в десятичном виде (без знака)
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
proc input_udec_word uses dx
	mov al,6					; Ввод максимум 5 символов (65535) + конец строки
	stdcall input_str			; Вызов процедуры ввода строки
	stdcall str_to_udec_word	; Преобразование строки в слово (без знака)
	ret
endp

; Процедура ввода байта с консоли в десятичном виде (без знака)
; выход: AL - байт (в случае ошибки AL = 0)
; CF = 1 - ошибка
proc input_udec_byte uses dx
	mov al,4					; Ввод максимум 3 символов (255) + конец строки
	stdcall input_str			; Вызов процедуры ввода строки
	stdcall str_to_udec_byte	; Преобразование строки в байт (без знака)
	ret
endp

; Процедура преобразования десятичной строки в слово со знаком
; вход: AL - длина строки
; DX - адрес строки, заканчивающейся символом CR(0Dh)
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
proc str_to_sdec_word uses bx dx
	test al,al					; Проверка длины строки
	jz stsdw_error				; Если равно 0, возвращаем ошибку
	mov bx,dx					; BX = адрес строки
	mov bl,[bx]					; BL = первый символ строки
	cmp bl,'-'					; Сравнение первого символа с "-"
	jne stsdw_no_sign			; Если не равно, то преобразуем как число без знака
	inc dx
	dec al
stsdw_no_sign:
	stdcall str_to_udec_word	; Преобразуем строку в слово без знака
	jc stsdw_exit				; Если ошибка, то возвращаем ошибку
	cmp bl,'-'					; Снова проверяем знак
	jne stsdw_plus				; Если первый символ не '-', то число положительное
	cmp ax,32768				; Модуль отрицательного числа должен быть не больше 32768
	ja stsdw_error				; Если больше (без знака), возвращаем ошибку
	neg ax						; Инвертируем число
	jmp stsdw_ok				; Переход к нормальному завершению процедуры
stsdw_plus:
	cmp ax,32767				; Положительное число должно быть не больше 32767
	ja stsdw_error				; Если больше (без знака), возвращаем ошибку

stsdw_ok:
	clc							; CF = 0
	jmp stsdw_exit				; Переход к выходу из процедуры
stsdw_error:
	xor ax,ax					; Обнуление AX
	stc							; CF = 1 (Возвращаем ошибку
stsdw_exit:
	ret
endp

; Процедура преобразования десятичной строки в байт со знаком
; вход: AL - длина строки
; DX - адрес строки, заканчивающейся символом CR(0Dh)
; выход: AL - байт (в случае ошибки AL = 0)
; CF = 1 - ошибка
proc str_to_sdec_byte uses dx
	push ax
	stdcall str_to_sdec_word	; Преобразование строки в слово (со знаком)
	jc stsdb_exit				; Если ошибка, то возвращаем ошибку
	cmp ax,127					; Сравнение результата с 127
	jg stsdb_error				; Если больше - ошибка
	cmp ax,-128					; Сравнение результата с -128
	jl stsdb_error				; Если меньше - ошибка
	clc							; CF = 0
	jmp stsdb_exit				; Переход к выходу из процедуры
stsdb_error:
	xor al,al					; Обнуление
	stc							; CF = 1 (Возвращаем ошибку)
stsdb_exit:
	pop dx
	mov ah,dh					; Восстановление только старшей части AX
	ret
endp

; Процедура ввода слова с консоли в десятичном виде (со знаком)
; выход: AX - слово (в случае ошибки AX = 0)
; CF = 1 - ошибка
proc input_sdec_word uses dx
	mov al,7					; Ввод максимум 6 символов (-32768) + конец строки
	stdcall input_str			; Вызов процедуры ввода строки
	stdcall str_to_sdec_word	; Преобразование строки в слово (со знаком)
	ret
endp

; Процедура ввода байта с консоли в десятичном виде (со знаком)
; выход: AL - байт (в случае ошибки AL = 0)
; CF = 1 - ошибка
proc input_sdec_byte uses dx
	mov al,5					; Ввод максимум 4 символов (-128) + конец строки
	stdcall input_str			; Вызов процедуры ввода строки
	stdcall str_to_sdec_byte	; Преобразование строки в байт (со знаком)
	ret
endp


/*---output---*/
/*---------------------------------------------------------------------------------------*/
; Процедура вывода байта на консоль в десятичном виде (без знака)
; AL - байт
proc print_byte_udec uses di
	mov di,buffer				; DI = адрес буфера
	push di						; Сохранение DI в стеке
	stdcall byte_to_udec_str	; Преобразование байта в AL в строку
	mov byte[di],'$'			; Добавление символа конца строки
	pop di						; DI = адрес начала строки
	stdcall print_str			; Вывод строки на консоль
	ret
endp

; Процедура вывода слова на консоль в десятичном виде (без знака)
; AX - слово
proc print_word_udec uses di
	mov di,buffer				; DI = адрес буфера
	push di						; Сохранение DI в стеке
	stdcall word_to_udec_str	; Преобразование слова в AX в строку
	mov byte[di],'$'			; Добавление символа конца строки
	pop di						; DI = адрес начала строки
	stdcall print_str			; Вывод строки на консоль
	ret
endp

; Процедура вывода байта на консоль в десятичном виде (со знаком)
; AL - байт
proc print_byte_sdec uses di
	mov di,buffer				; DI = адрес буфера
	push di						; Сохранение DI в стеке
	stdcall byte_to_sdec_str	; Преобразование байта в AL в строку
	mov byte[di],'$'			; Добавление символа конца строки
	pop di						; DI = адрес начала строки
	stdcall print_str			; Вывод строки на консоль
	ret
endp

; Процедура вывода слова на консоль в десятичном виде (со знаком)
; AX - слово
proc print_word_sdec uses di
	mov di,buffer				; DI = адрес буфера
	push di						; Сохранение DI в стеке
	stdcall word_to_sdec_str	; Преобразование слова в AX в строку
	mov byte[di],'$'			; Добавление символа конца строки
	pop di						; DI = адрес начала строки
	stdcall print_str			; Вывод строки на консоль
	ret
endp

; Процедура вывода строки на консоль
; DI - адрес строки
proc print_str uses ax
	mov ah,9	; Функция DOS 09h - вывод строки
	xchg dx,di	; Обмен значениями DX и DI
	int 21h		; Обращение к функции DOS
	xchg dx,di	; Обмен значениями DX и DI
	ret
endp

; Процедура вывода конца строки (CR+LF)
proc print_endline uses di
	mov di,endline				; DI = адрес строки с символами CR,LF
	stdcall print_str			; Вывод строки на консоль
	ret
endp

; Процедура преобразования байта в строку в десятичном виде (без знака)
; AL - байт.
; DI - буфер для строки (3 символа). Значение регистра не сохраняется.
proc byte_to_udec_str uses ax
	xor ah,ah					; Преобразование байта в слово (без знака)
	stdcall word_to_udec_str	; Вызов процедуры для слова без знака
	ret
endp

; Процедура преобразования слова в строку в десятичном виде (без знака)
; AX - слово
; DI - буфер для строки (5 символов). Значение регистра не сохраняется.
proc word_to_udec_str uses ax cx dx bx
	xor cx,cx		; Обнуление CX
	mov bx,10		; В BX делитель (10 для десятичной системы)

wtuds_lp1:			; Цикл получения остатков от деления
	xor dx,dx		; Обнуление старшей части двойного слова
	div bx			; Деление AX=(DX:AX)/BX,остаток в DX
	add dl,'0'		; Преобразование остатка в код символа
	push dx			; Сохранение в стеке
	inc cx			; Увеличение счетчика символов
	test ax,ax		; Проверка AX
	jnz wtuds_lp1	; Переход к началу цикла,если частное не 0.

wtuds_lp2:			; Цикл извлечения символов из стека
	pop dx			; Восстановление символа из стека
	mov [di],dl 	; Сохранение символа в буфере
	inc di			; Инкремент адреса буфера
	loop wtuds_lp2	; Команда цикла
	ret
endp

; Процедура преобразования байта в строку в десятичном виде (со знаком)
; AL - байт.
; DI - буфер для строки (4 символа). Значение регистра не сохраняется.
proc byte_to_sdec_str uses ax
	movsx ax,al 				; Преобразование байта в слово (со знаком)
	stdcall word_to_sdec_str	; Вызов процедуры для слова со знаком
	ret
endp

; Процедура преобразования слова в строку в десятичном виде (со знаком)
; AX - слово
; DI - буфер для строки (6 символов). Значение регистра не сохраняется.
proc word_to_sdec_str uses ax
	test ax,ax					; Проверка знака AX
	jns wtsds_no_sign			; Если >= 0,преобразуем как беззнаковое
	mov byte[di],'-'			; Добавление знака в начало строки
	inc di						; Инкремент DI
	neg ax						; Изменение знака значения AX
wtsds_no_sign:
	stdcall word_to_udec_str	; Преобразование беззнакового значения
	ret
endp
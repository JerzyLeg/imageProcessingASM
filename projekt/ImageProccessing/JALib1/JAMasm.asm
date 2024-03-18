;*******************************************************************************
;Temat: Sobel operator 
;Semestr: Zimowy, Rok: 2023/2024
;Autor: Jerzy Legaszewski
;
;Algorytm s�u�y do wykrywania kraw�dzi. Sk�ada si� z 3 procedur:
; 1) obliczeniu gradientu poziomego
;   
;         |1  0  -1|
;    Gx = |2  0  -2| * A
;         |1  0  -1|
;
;   Procedura w asm: GradientX
;   
; 2) obliczenie gradientu pionowego
;
;         | 1  2  1|
;    Gy = | 0  0  0| * A
;         |-1 -2 -1|
;
;   Procedura w asm: GradientY  
;
; 3) obliczenie gradientu wynikowego
;       
;    G = |Gx| + |Gy|
;
;   Procedura w asm: Fusion
;
;*******************************************************************************

.data
index dq 0
ret_ptr dq 0


;Inicjalizacja wsp�czynnik�w
;GradientX
gx_left_top dw -1
gx_left_middle dw -2
gx_left_down dw -1
gx_right_top dw 1
gx_right_middle dw 2
gx_right_down dw 1

;GradientY
gy_top_left dw 1
gy_top_middle dw 2
gy_top_right dw 1
gy_down_left dw -1
gy_down_middle dw -2
gy_down_right dw -1


.code

; Funkcja zapisuj�ca do macierzy wynikowej short�w, pixele z gradientem poziomym.
GradientX proc

; Argumenty funkcji
    ; RCX - wska�nik do tablicy bajt�w,  input, 1 pixel ma rozmiar 1 bajt
    ; RDX - wska�nik do tablicy short�w, output, 1 pixel ma rozmiar 2 bajty
    ; R8  - szeroko�� obrazu
    ; R9  - wysoko�� obrazu

    mov ret_ptr, R14 ; ret ptr     ; zapisuje adres powrotu na stosie
    push r14                       ; zapisuje warto�� rejestru R14 na stosie
    push rdi                       ; zapisuje warto�� rejestru RDI na stosie

    ; Inicjalizacja iterator�w dla wierszy i kolumn
    mov r13, 0                     ; ustawia iterator dla wierszy na 0

    ; P�tla dla wierszy (outer loop)
    rows_loop:
        ; Inicjalizacja iteratora kolumn
        mov r12, 0                  ; ustawia iterator dla kolumn na 0

        ; P�tla dla kolumn (inner loop)
        columns_loop:

            ; Sprawd�, czy jeste�my na pierwszym lub ostatnim wierszu lub kolumnie
            cmp r13, 0               ; por�wnuje iterator dla wierszy z 0
            je paint_it_black        ; je�li r�wny 0, przejd� do etykiety paint_it_black
            
            mov index, r9            ; zapisuje wysoko�� obrazu w zmiennej index
            sub index, 1             ; odejmuje 1 od warto�ci index
            cmp r13, index           ; por�wnuje iterator dla wierszy z index
            jge paint_it_black       ; je�li iterator dla wierszy wi�kszy lub r�wny index, przejd� do etykiety paint_it_black
            cmp r12, 0               ; por�wnuje iterator dla kolumn z 0
            je paint_it_black        ; je�li r�wny 0, przejd� do etykiety paint_it_black

            mov index, r8            ; zapisuje warto�� szeroko�� obrazu w zmiennej index
            sub index, 1             ; odejmuje 1 od warto�ci index
            cmp r12, index           ; por�wnuje iterator dla kolumn z index
            jge paint_it_black       ; je�li iterator dla kolumn wi�kszy lub r�wny index, przejd� do etykiety paint_it_black

            ; Inicjalizacja zmiennych macierzy pomocniczej
            mov gx_left_top, -1             ; inicjalizuje zmienn� gx_left_top na -1
            mov gx_left_middle, -2          ; inicjalizuje zmienn� gx_left_middle na -2
            mov gx_left_down, -1            ; inicjalizuje zmienn� gx_left_down na -1
            mov gx_right_top, 1             ; inicjalizuje zmienn� gx_right_top na 1
            mov gx_right_middle, 2          ; inicjalizuje zmienn� gx_right_middle na 2
            mov gx_right_down, 1            ; inicjalizuje zmienn� gx_right_down na 1

            ; Za�aduj offset obrazu wejsciowego do r14
            mov r14, r8                     ; zapisuje szeroko�� obrazka w r14
            imul r14, r13                   ; mno�y przez iterator dla wierszy
            add r14, r12                    ; dodaje iterator dla kolumn do r14

            ; Przemn� i dodaj s�siad�w do zmiennych
            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            sub rsi, r8                     ; odejmuje szerko�� od rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_top             ; zapisuje warto�� gx_left_top w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di                     ; mno�y ax przez dil
            mov gx_left_top, ax             ; zapisuje warto�� ax do gx_left_top

            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_middle          ; zapisuje warto�� gx_left_middle w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di                     ; mno�y ax przez dil
            mov gx_left_middle, ax          ; zapisuje warto�� ax do gx_left_middle


            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            add rsi, r8                     ; dodaje 1 do rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_down            ; zapisuje warto�� gx_left_down w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di                     ; mno�y ax przez dil
            mov gx_left_down, ax            ; zapisuje warto�� ax do gx_left_down

            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            sub rsi, r8                     ; odejmuje szerko�� od rsi
            add rsi, 1                      ; dodaje 1 do rsi 

            mov ax, gx_right_top            ; zapisuje warto�� gx_right_top w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di                     ; mno�y ax przez dil
            mov gx_right_top, ax            ; zapisuje warto�� ax do gx_right_top

            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            add rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_right_middle         ; zapisuje warto�� gx_right_middle w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di                     ; mno�y ax przez dil
            mov gx_right_middle, ax         ; zapisuje warto�� ax do gx_right_middle

            mov rsi, r14                    ; zapisuje warto�� r14 w rsi
            add rsi, r8                     ; dodaje szeroko�� do rsi
            add rsi, 1                      ; dodaje 1 do rsi

            mov ax, gx_right_down           ; zapisuje warto�� gx_right_down w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje warto�� z tablicy bajt�w do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bit�w z r11w do dil
            imul ax, di ; left_middle       ; mno�y ax przez dil
            mov gx_right_down, ax           ; zapisuje warto�� ax do gx_right_down

            ; Zsumuj zmienne przed zapisaniem do macierzy wynikowej
            mov ax, gx_right_top            ; Przypisz warto�� zmiennej gx_right_top do rejestru AX
            add ax, gx_right_middle         ; Dodaj warto�� zmiennej gx_right_middle do rejestru AX
            add ax, gx_right_down           ; Dodaj warto�� zmiennej gx_right_down do rejestru AX
            add ax, gx_left_top             ; Dodaj warto�� zmiennej gx_left_top do rejestru AX
            add ax, gx_left_middle          ; Dodaj warto�� zmiennej gx_left_middle do rejestru AX
            add ax, gx_left_down            ; Dodaj warto�� zmiennej gx_left_down do rejestru AX
            

            ; Za�aduj offset obrazu wyjsciowego do r15
            ;R15 = R8*R13*2 + R12*2
            mov r15, r8                     ; Przypisz warto�� szeroko�ci obrazu do rejestru R15
            imul r15, r13                   ; Pomn� szeroko�� obrazu przez iterator dla wierszy i zapisz wynik w R15
            imul r15, 2                     ; Pomn� R15 przez 2 (1 pixel = 2 bajty)
            mov r10, r12                    ; Przypisz warto�� iteratora dla kolumn do rejestru R10
            imul r10, 2                     ; Pomn� iterator dla kolumn przez 2 (1 pixel = 2 bajty)
            add r15, r10                    ; Dodaj warto�� R10 do R15, co odpowiada po�o�eniu aktualnego piksela w buforze obrazu

            ; Zapisz zmodyfikowan� warto�� do tablicy wynikowej
            mov [rdx][r15], ax  ; Zapisz 16-bitow� warto�� do tablicy wynikowej


            jmp Continue                    ; Skocz do ko�ca bloku ustawiania na czarno
        
        paint_it_black:
            mov ax, 0                       ; Ustaw na kolor czarny

            mov r15, r8                     ; Przypisz warto�� szeroko�ci obrazu do rejestru R15
            imul r15, r13                   ; Pomn� szeroko�� obrazu przez iterator dla wierszy i zapisz wynik w R15
            imul r15, 2                     ; Pomn� R15 przez 2 (1 pixel = 2 bajty)
            mov r10, r12                    ; Przypisz warto�� iteratora dla kolumn do rejestru R10
            imul r10, 2                     ; Pomn� iterator dla kolumn przez 2 (1 pixel = 2 bajty)
            add r15, r10                    ; Dodaj warto�� R10 do R15, co odpowiada po�o�eniu aktualnego piksela w buforze obrazu
            add r15, rdx                    ; Dodaj adres obrazu wynikowego do r15

            mov word ptr [r15], ax          ; Zapisz zmodyfikowan� warto�� do tablicy wynikowej

        Continue:

            ; Inkrementuj iterator kolumn
            inc r12                         ; Inkrementuj iterator kolumn

            ; Sprawd� warunek zako�czenia p�tli dla kolumn
            cmp r12, r8                     ; Sprawd� czy iterator kolumn jest mniejszy ni� szeroko�� obrazu
            jl columns_loop                 ; Je�li mniejszy, id� do p�tli
                
        ; Inkrementuj iterator wierszy
        inc r13                             ; Inkrementuj iterator wierszy

        ; Sprawd� warunek zako�czenia p�tli dla wierszy
        cmp r13, r9                         ; Sprawd� czy iterator wierszy jest mniejszy ni� wysoko�� obrazu
        jl rows_loop                        ; Je�li mniejszy, id� do p�tli

    ; Koniec funkcji
    pop rdi                                 ; Przywraca poprzedni� warto�� rejestru RDI
    pop r14                                 ; Przywraca poprzedni� warto�� rejestru R14
    mov r14, ret_ptr                        ; Ustawia wska�nik powrotu funkcji
    ret                                     ; Powr�t z funkcji

GradientX endp


; Funkcja zapisuj�ca do macierzy wynikowej short�w, pixele z gradientem pionowym.
; Procedura GradientY robi dok�adnie to samo co GradientX,
; dlatego nie b�dzie skomentowana linia po lini. Jedyna r�nica polega na braniu s�siad�w o r�nych indeksach 
; i zapisywaniu do innych zmiennych, jednak mechanizm dzia�ania jest identyczny.

GradientY proc
; Argumenty funkcji
    ; RCX - wska�nik do tablicy bajt�w,  input, 1 pixel ma rozmiar 1 bajt
    ; RDX - wska�nik do tablicy short�w, output, 1 pixel ma rozmiar 2 bajty
    ; R8  - szeroko�� obrazu
    ; R9  - wysoko�� obrazu

    mov ret_ptr, R14 ; ret ptr
    push r14
    push rdi

    ; Inicjalizacja iterator�w dla wierszy i kolumn
    mov r13, 0  ; iterator dla wierszy

    ; P�tla dla wierszy (outer loop)
    rows_loop:
        ; Inicjalizacja iteratora kolumn
        mov r12, 0  ; iterator dla kolumn

        ; P�tla dla kolumn (inner loop)
        columns_loop:

            ; Sprawd�, czy jeste�my na pierwszym lub ostatnim wierszu lub kolumnie
            cmp r13, 0
            je paint_it_black
            
            mov index, r9
            sub index, 1
            cmp r13, index
            jge paint_it_black
            cmp r12, 0
            je paint_it_black

            mov index, r8
            sub index, 1
            cmp r12, index
            jge paint_it_black

            ; Inicjalizacja zmiennych
            mov gy_top_left, 1
            mov gy_top_middle, 2
            mov gy_top_right, 1
            mov gy_down_left, -1
            mov gy_down_middle, -2
            mov gy_down_right, -1

            ; Za�aduj offset obrazu wejsciowego do r14
            mov r14, r8
            imul r14, r13
            add r14, r12
            ;add r14, rcx

            ; Przemn� i dodaj s�siad�w do zmiennych
            mov rsi, r14
            sub rsi, r8
            sub rsi, 1

            mov ax, gy_top_left
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_left
            mov gy_top_left, ax


            mov rsi, r14
            sub rsi, r8

            mov ax, gy_top_middle
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_middle
            mov gy_top_middle, ax


            mov rsi, r14
            sub rsi, r8
            add rsi, 1

            mov ax, gy_top_right
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_middle
            mov gy_top_middle, ax


            mov rsi, r14
            add rsi, r8
            sub rsi, 1

            mov ax, gy_down_left
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_middle
            mov gy_top_middle, ax


            mov rsi, r14
            add rsi, r8

            mov ax, gy_down_middle
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_middle
            mov gy_top_middle, ax


            mov rsi, r14
            add rsi, r8
            add rsi, 1

            mov ax, gy_down_right
            xor rdi, rdi
            mov r11w, [rcx][rsi]
            mov dil, r11b
            imul ax, di ; top_middle
            mov gy_top_middle, ax

            ; Zsumuj zmienne przed zapisaniem do macierzy wynikowej
            mov ax, gy_top_left
            add ax, gy_top_middle
            add ax, gy_top_right
            add ax, gy_down_left
            add ax, gy_down_middle
            add ax, gy_down_right

            ; Za�aduj offset obrazu wyjsciowego do r15

            mov r15, r8
            imul r15, r13
            imul r15, 2
            mov r10, r12
            imul r10, 2
            add r15, r10
            ;add r15, rdx

            ; Zapisz zmodyfikowan� warto�� do tablicy wynikowej
            mov [rdx][r15], ax  ; Zapisz 16-bitow� warto�� do tablicy wynikowej


            jmp Continue  ; Skocz do ko�ca bloku ustawiania na czarno
        
        paint_it_black:
            mov ax, 0  ; Ustaw na kolor czarny

            mov r15, r8
            imul r15, r13
            imul r15, 2
            mov r10, r12
            imul r10, 2
            add r15, r10
            add r15, rdx

            mov word ptr [r15], ax

        Continue:

            ; Inkrementuj iterator kolumn
            inc r12

            ; Sprawd� warunek zako�czenia p�tli dla kolumn
            cmp r12, r8
            jl columns_loop

        ; Inkrementuj iterator wierszy
        inc r13

        ; Sprawd� warunek zako�czenia p�tli dla wierszy
        cmp r13, r9
        jl rows_loop

    ; Koniec funkcji
    pop rdi
    pop r14
    mov r14, ret_ptr;
    ret
GradientY endp


; Ta funkcja bierze dwie tablice short, a nast�pnie sumuje warto�ci bezwzgl�dne pikseli z tych tablic. 
; Wynikowy piksel jest zaw�any do przedzia�u 0-255, aby zmie�ci� si� w bajcie.
Fusion proc
    ; Argumenty funkcji
    ; rcx - wska�nik do tablicy wynikowej GradientX, tab[short]
    ; rdx - wska�nik do tablicy wynikowej GradientY, tab[short]
    ; r8  - wynikowa tablica bajt�w tab3
    ; r9  - rozmiar tablic

    xor eax, eax                ; Wyczy�� rejestr eax przed rozpocz�ciem

    sum_loop:
        cmp r9, 0               ; Sprawd�, czy doszli�my do ko�ca tablicy
        je  end_sum             ; Je�li tak, zako�cz sumowanie

        ; Wczytaj elementy z tablic tab1 i tab2 do rejestr�w bx i r10w
        xor ebx, ebx            ; Wyczy�� ebx
        xor r10, r10            ; Wyczy�� r10
        mov ebx, [rcx]          ; Wczytaj warto�� z tablicy rcx do ebx
        mov r10d, [rdx]         ; Wczytaj warto�� z tablicy rdx do r10d

        ; Zapisz sum� bezwzgl�dnych warto�ci w 32-bitowym rejestrze
        cmp bx, 0               ; Por�wnaj warto�� w ebx z 0
        jl negative_value_bx ; Je�li mniejsza, skocz do negative_value_bx
    continue:
        cmp r10w, 0             ; Por�wnaj warto�� w r10w z 0
        jl negative_value_cx    ; Je�li mniejsza, skocz do negative_value_cx
        mov ax, bx              ; Przypisz warto�� z ebx do ax
        add ax, r10w            ; Dodaj warto�� z r10w do ax

    second_num:

        ; Sprawd�, czy wynik jest wi�kszy ni� 255
        cmp ax, 255             ; Por�wnaj warto�� w ax z 255
        jle   not_max_value     ; Je�li mniejsza lub r�wna, przejd� do not_max_value

        ; Wynik jest wi�kszy ni� 255, ustaw na 255
        mov ax, 0               ; Ustaw warto�� ax na 0

    not_max_value:
        ; Zapisz wynik w tablicy bajt�w
        mov [r8], al            ; Zapisz zawarto�� al do adresu w r8

        ; Przesu� wska�niki na kolejne elementy tablic
        add rcx, 2              ; Dodaj 2 do rcx
        add rdx, 2              ; Dodaj 2 do rdx
        inc r8                  ; Inkrementuj r8
        dec r9                  ; Dekrementuj r9
        jmp sum_loop            ; Skocz do sum_loop

    negative_value_bx:
        not ebx                 ; Neguj warto�� w ebx
        add ebx, 1              ; Dodaj 1 do ebx
        jmp continue            ; Wr�� do continue

    negative_value_cx:
        not r10w                ; Neguj warto�� w r10w
        add r10w, 1             ; Dodaj 1 do r10w
        jmp continue            ; Wr�� do continue

    end_sum:
        ret                     ; Zako�cz funkcj�

Fusion endp
end

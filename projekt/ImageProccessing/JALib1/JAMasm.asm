;*******************************************************************************
;Temat: Sobel operator 
;Semestr: Zimowy, Rok: 2023/2024
;Autor: Jerzy Legaszewski
;
;Algorytm s³u¿y do wykrywania krawêdzi. Sk³ada siê z 3 procedur:
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


;Inicjalizacja wspó³czynników
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

; Funkcja zapisuj¹ca do macierzy wynikowej shortów, pixele z gradientem poziomym.
GradientX proc

; Argumenty funkcji
    ; RCX - wskaŸnik do tablicy bajtów,  input, 1 pixel ma rozmiar 1 bajt
    ; RDX - wskaŸnik do tablicy shortów, output, 1 pixel ma rozmiar 2 bajty
    ; R8  - szerokoœæ obrazu
    ; R9  - wysokoœæ obrazu

    mov ret_ptr, R14 ; ret ptr     ; zapisuje adres powrotu na stosie
    push r14                       ; zapisuje wartoœæ rejestru R14 na stosie
    push rdi                       ; zapisuje wartoœæ rejestru RDI na stosie

    ; Inicjalizacja iteratorów dla wierszy i kolumn
    mov r13, 0                     ; ustawia iterator dla wierszy na 0

    ; Pêtla dla wierszy (outer loop)
    rows_loop:
        ; Inicjalizacja iteratora kolumn
        mov r12, 0                  ; ustawia iterator dla kolumn na 0

        ; Pêtla dla kolumn (inner loop)
        columns_loop:

            ; SprawdŸ, czy jesteœmy na pierwszym lub ostatnim wierszu lub kolumnie
            cmp r13, 0               ; porównuje iterator dla wierszy z 0
            je paint_it_black        ; jeœli równy 0, przejdŸ do etykiety paint_it_black
            
            mov index, r9            ; zapisuje wysokoœæ obrazu w zmiennej index
            sub index, 1             ; odejmuje 1 od wartoœci index
            cmp r13, index           ; porównuje iterator dla wierszy z index
            jge paint_it_black       ; jeœli iterator dla wierszy wiêkszy lub równy index, przejdŸ do etykiety paint_it_black
            cmp r12, 0               ; porównuje iterator dla kolumn z 0
            je paint_it_black        ; jeœli równy 0, przejdŸ do etykiety paint_it_black

            mov index, r8            ; zapisuje wartoœæ szerokoœæ obrazu w zmiennej index
            sub index, 1             ; odejmuje 1 od wartoœci index
            cmp r12, index           ; porównuje iterator dla kolumn z index
            jge paint_it_black       ; jeœli iterator dla kolumn wiêkszy lub równy index, przejdŸ do etykiety paint_it_black

            ; Inicjalizacja zmiennych macierzy pomocniczej
            mov gx_left_top, -1             ; inicjalizuje zmienn¹ gx_left_top na -1
            mov gx_left_middle, -2          ; inicjalizuje zmienn¹ gx_left_middle na -2
            mov gx_left_down, -1            ; inicjalizuje zmienn¹ gx_left_down na -1
            mov gx_right_top, 1             ; inicjalizuje zmienn¹ gx_right_top na 1
            mov gx_right_middle, 2          ; inicjalizuje zmienn¹ gx_right_middle na 2
            mov gx_right_down, 1            ; inicjalizuje zmienn¹ gx_right_down na 1

            ; Za³aduj offset obrazu wejsciowego do r14
            mov r14, r8                     ; zapisuje szerokoœæ obrazka w r14
            imul r14, r13                   ; mno¿y przez iterator dla wierszy
            add r14, r12                    ; dodaje iterator dla kolumn do r14

            ; Przemnó¿ i dodaj s¹siadów do zmiennych
            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            sub rsi, r8                     ; odejmuje szerkoœæ od rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_top             ; zapisuje wartoœæ gx_left_top w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di                     ; mno¿y ax przez dil
            mov gx_left_top, ax             ; zapisuje wartoœæ ax do gx_left_top

            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_middle          ; zapisuje wartoœæ gx_left_middle w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di                     ; mno¿y ax przez dil
            mov gx_left_middle, ax          ; zapisuje wartoœæ ax do gx_left_middle


            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            add rsi, r8                     ; dodaje 1 do rsi
            sub rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_left_down            ; zapisuje wartoœæ gx_left_down w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di                     ; mno¿y ax przez dil
            mov gx_left_down, ax            ; zapisuje wartoœæ ax do gx_left_down

            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            sub rsi, r8                     ; odejmuje szerkoœæ od rsi
            add rsi, 1                      ; dodaje 1 do rsi 

            mov ax, gx_right_top            ; zapisuje wartoœæ gx_right_top w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di                     ; mno¿y ax przez dil
            mov gx_right_top, ax            ; zapisuje wartoœæ ax do gx_right_top

            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            add rsi, 1                      ; odejmuje 1 od rsi

            mov ax, gx_right_middle         ; zapisuje wartoœæ gx_right_middle w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di                     ; mno¿y ax przez dil
            mov gx_right_middle, ax         ; zapisuje wartoœæ ax do gx_right_middle

            mov rsi, r14                    ; zapisuje wartoœæ r14 w rsi
            add rsi, r8                     ; dodaje szerokoœæ do rsi
            add rsi, 1                      ; dodaje 1 do rsi

            mov ax, gx_right_down           ; zapisuje wartoœæ gx_right_down w ax
            xor rdi, rdi                    ; zeruje rdi
            mov r11w, [rcx][rsi]            ; zapisuje wartoœæ z tablicy bajtów do r11w
            mov dil, r11b                   ; zapisuje niskie 8 bitów z r11w do dil
            imul ax, di ; left_middle       ; mno¿y ax przez dil
            mov gx_right_down, ax           ; zapisuje wartoœæ ax do gx_right_down

            ; Zsumuj zmienne przed zapisaniem do macierzy wynikowej
            mov ax, gx_right_top            ; Przypisz wartoœæ zmiennej gx_right_top do rejestru AX
            add ax, gx_right_middle         ; Dodaj wartoœæ zmiennej gx_right_middle do rejestru AX
            add ax, gx_right_down           ; Dodaj wartoœæ zmiennej gx_right_down do rejestru AX
            add ax, gx_left_top             ; Dodaj wartoœæ zmiennej gx_left_top do rejestru AX
            add ax, gx_left_middle          ; Dodaj wartoœæ zmiennej gx_left_middle do rejestru AX
            add ax, gx_left_down            ; Dodaj wartoœæ zmiennej gx_left_down do rejestru AX
            

            ; Za³aduj offset obrazu wyjsciowego do r15
            ;R15 = R8*R13*2 + R12*2
            mov r15, r8                     ; Przypisz wartoœæ szerokoœci obrazu do rejestru R15
            imul r15, r13                   ; Pomnó¿ szerokoœæ obrazu przez iterator dla wierszy i zapisz wynik w R15
            imul r15, 2                     ; Pomnó¿ R15 przez 2 (1 pixel = 2 bajty)
            mov r10, r12                    ; Przypisz wartoœæ iteratora dla kolumn do rejestru R10
            imul r10, 2                     ; Pomnó¿ iterator dla kolumn przez 2 (1 pixel = 2 bajty)
            add r15, r10                    ; Dodaj wartoœæ R10 do R15, co odpowiada po³o¿eniu aktualnego piksela w buforze obrazu

            ; Zapisz zmodyfikowan¹ wartoœæ do tablicy wynikowej
            mov [rdx][r15], ax  ; Zapisz 16-bitow¹ wartoœæ do tablicy wynikowej


            jmp Continue                    ; Skocz do koñca bloku ustawiania na czarno
        
        paint_it_black:
            mov ax, 0                       ; Ustaw na kolor czarny

            mov r15, r8                     ; Przypisz wartoœæ szerokoœci obrazu do rejestru R15
            imul r15, r13                   ; Pomnó¿ szerokoœæ obrazu przez iterator dla wierszy i zapisz wynik w R15
            imul r15, 2                     ; Pomnó¿ R15 przez 2 (1 pixel = 2 bajty)
            mov r10, r12                    ; Przypisz wartoœæ iteratora dla kolumn do rejestru R10
            imul r10, 2                     ; Pomnó¿ iterator dla kolumn przez 2 (1 pixel = 2 bajty)
            add r15, r10                    ; Dodaj wartoœæ R10 do R15, co odpowiada po³o¿eniu aktualnego piksela w buforze obrazu
            add r15, rdx                    ; Dodaj adres obrazu wynikowego do r15

            mov word ptr [r15], ax          ; Zapisz zmodyfikowan¹ wartoœæ do tablicy wynikowej

        Continue:

            ; Inkrementuj iterator kolumn
            inc r12                         ; Inkrementuj iterator kolumn

            ; SprawdŸ warunek zakoñczenia pêtli dla kolumn
            cmp r12, r8                     ; SprawdŸ czy iterator kolumn jest mniejszy ni¿ szerokoœæ obrazu
            jl columns_loop                 ; Jeœli mniejszy, idŸ do pêtli
                
        ; Inkrementuj iterator wierszy
        inc r13                             ; Inkrementuj iterator wierszy

        ; SprawdŸ warunek zakoñczenia pêtli dla wierszy
        cmp r13, r9                         ; SprawdŸ czy iterator wierszy jest mniejszy ni¿ wysokoœæ obrazu
        jl rows_loop                        ; Jeœli mniejszy, idŸ do pêtli

    ; Koniec funkcji
    pop rdi                                 ; Przywraca poprzedni¹ wartoœæ rejestru RDI
    pop r14                                 ; Przywraca poprzedni¹ wartoœæ rejestru R14
    mov r14, ret_ptr                        ; Ustawia wskaŸnik powrotu funkcji
    ret                                     ; Powrót z funkcji

GradientX endp


; Funkcja zapisuj¹ca do macierzy wynikowej shortów, pixele z gradientem pionowym.
; Procedura GradientY robi dok³adnie to samo co GradientX,
; dlatego nie bêdzie skomentowana linia po lini. Jedyna ró¿nica polega na braniu s¹siadów o róŸnych indeksach 
; i zapisywaniu do innych zmiennych, jednak mechanizm dzia³ania jest identyczny.

GradientY proc
; Argumenty funkcji
    ; RCX - wskaŸnik do tablicy bajtów,  input, 1 pixel ma rozmiar 1 bajt
    ; RDX - wskaŸnik do tablicy shortów, output, 1 pixel ma rozmiar 2 bajty
    ; R8  - szerokoœæ obrazu
    ; R9  - wysokoœæ obrazu

    mov ret_ptr, R14 ; ret ptr
    push r14
    push rdi

    ; Inicjalizacja iteratorów dla wierszy i kolumn
    mov r13, 0  ; iterator dla wierszy

    ; Pêtla dla wierszy (outer loop)
    rows_loop:
        ; Inicjalizacja iteratora kolumn
        mov r12, 0  ; iterator dla kolumn

        ; Pêtla dla kolumn (inner loop)
        columns_loop:

            ; SprawdŸ, czy jesteœmy na pierwszym lub ostatnim wierszu lub kolumnie
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

            ; Za³aduj offset obrazu wejsciowego do r14
            mov r14, r8
            imul r14, r13
            add r14, r12
            ;add r14, rcx

            ; Przemnó¿ i dodaj s¹siadów do zmiennych
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

            ; Za³aduj offset obrazu wyjsciowego do r15

            mov r15, r8
            imul r15, r13
            imul r15, 2
            mov r10, r12
            imul r10, 2
            add r15, r10
            ;add r15, rdx

            ; Zapisz zmodyfikowan¹ wartoœæ do tablicy wynikowej
            mov [rdx][r15], ax  ; Zapisz 16-bitow¹ wartoœæ do tablicy wynikowej


            jmp Continue  ; Skocz do koñca bloku ustawiania na czarno
        
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

            ; SprawdŸ warunek zakoñczenia pêtli dla kolumn
            cmp r12, r8
            jl columns_loop

        ; Inkrementuj iterator wierszy
        inc r13

        ; SprawdŸ warunek zakoñczenia pêtli dla wierszy
        cmp r13, r9
        jl rows_loop

    ; Koniec funkcji
    pop rdi
    pop r14
    mov r14, ret_ptr;
    ret
GradientY endp


; Ta funkcja bierze dwie tablice short, a nastêpnie sumuje wartoœci bezwzglêdne pikseli z tych tablic. 
; Wynikowy piksel jest zawê¿any do przedzia³u 0-255, aby zmieœci³ siê w bajcie.
Fusion proc
    ; Argumenty funkcji
    ; rcx - wskaŸnik do tablicy wynikowej GradientX, tab[short]
    ; rdx - wskaŸnik do tablicy wynikowej GradientY, tab[short]
    ; r8  - wynikowa tablica bajtów tab3
    ; r9  - rozmiar tablic

    xor eax, eax                ; Wyczyœæ rejestr eax przed rozpoczêciem

    sum_loop:
        cmp r9, 0               ; SprawdŸ, czy doszliœmy do koñca tablicy
        je  end_sum             ; Jeœli tak, zakoñcz sumowanie

        ; Wczytaj elementy z tablic tab1 i tab2 do rejestrów bx i r10w
        xor ebx, ebx            ; Wyczyœæ ebx
        xor r10, r10            ; Wyczyœæ r10
        mov ebx, [rcx]          ; Wczytaj wartoœæ z tablicy rcx do ebx
        mov r10d, [rdx]         ; Wczytaj wartoœæ z tablicy rdx do r10d

        ; Zapisz sumê bezwzglêdnych wartoœci w 32-bitowym rejestrze
        cmp bx, 0               ; Porównaj wartoœæ w ebx z 0
        jl negative_value_bx ; Jeœli mniejsza, skocz do negative_value_bx
    continue:
        cmp r10w, 0             ; Porównaj wartoœæ w r10w z 0
        jl negative_value_cx    ; Jeœli mniejsza, skocz do negative_value_cx
        mov ax, bx              ; Przypisz wartoœæ z ebx do ax
        add ax, r10w            ; Dodaj wartoœæ z r10w do ax

    second_num:

        ; SprawdŸ, czy wynik jest wiêkszy ni¿ 255
        cmp ax, 255             ; Porównaj wartoœæ w ax z 255
        jle   not_max_value     ; Jeœli mniejsza lub równa, przejdŸ do not_max_value

        ; Wynik jest wiêkszy ni¿ 255, ustaw na 255
        mov ax, 0               ; Ustaw wartoœæ ax na 0

    not_max_value:
        ; Zapisz wynik w tablicy bajtów
        mov [r8], al            ; Zapisz zawartoœæ al do adresu w r8

        ; Przesuñ wskaŸniki na kolejne elementy tablic
        add rcx, 2              ; Dodaj 2 do rcx
        add rdx, 2              ; Dodaj 2 do rdx
        inc r8                  ; Inkrementuj r8
        dec r9                  ; Dekrementuj r9
        jmp sum_loop            ; Skocz do sum_loop

    negative_value_bx:
        not ebx                 ; Neguj wartoœæ w ebx
        add ebx, 1              ; Dodaj 1 do ebx
        jmp continue            ; Wróæ do continue

    negative_value_cx:
        not r10w                ; Neguj wartoœæ w r10w
        add r10w, 1             ; Dodaj 1 do r10w
        jmp continue            ; Wróæ do continue

    end_sum:
        ret                     ; Zakoñcz funkcjê

Fusion endp
end

; Мелехин Денис БПИ198
; 20 вариант
; Задача: Разработать программу, которая принимает на вход размер массива
; и массив соответствующего размера, после чего меняет значение минимального
; и первого элементов местами

format PE console
                                                                                                               
include 'win32a.inc'                                                                                           
                                                                                                               
entry start                                                                                                    
                                                                                                               
section '.data' data readable writable

        wrong_size      db    'Wrong size of array!',  10, 0

        bracket2        db    '}',                     10, 0

        ask_size        db    'Write size of array pls: ', 0
                                                                                           
        elem_int        db    '(%d): ',                    0
                                                                         
        only_d          db    '%d',                        0
                                                                                                                                             
        bracket1        db    '{',                         0
                                                                                                                                     
        oneSymb         db    '%d ',                       0


        size            dd       0    ; Размер массива
                                                                                                                                                                  
        my_array        rd     100    ; Введенный массив
                                                                                                                                                              
        i               dd       ?
                                                                    
        tmp             dd       ?
                                                                                                                                                     
        point           dd       ?
                                                                                                                                                         
        flag            dd       1

        min             dd       ?    ; Минимальный элемент массива

        first           dd       ?    ; Первый элемент массива
                                                                                                               
        NULL = 0                                                                                               
                                                                                                               
                                                                                                               
section '.code' code readable executable

        start:                                                                                                 
                input_again:
                ; Запрашиваем ввод у пользователя
                push ask_size                                                                                
                call [printf]
                                                                                                               
                push size                                                                                 
                push only_d                                                                                
                call [scanf]                                                                                   

                mov eax, [size]                                                                          
                cmp eax, 0                                                                                    
                jle wrong_input                                                                             
                jg ok_input

        ; Действия при некоррректном вводе
        wrong_input:
                push wrong_size                                                                              
                call [printf]                                                                                  
                jmp input_again                                                                                  

        ; Действия при корректном вводе
        ok_input:
                ; Считываем массив
                push [size]                                                                               
                push my_array                                                                                      
                call read_array
                ; Находим минимум
                call find_minimum

                ; Меняем местами первый и минимальный
                call swap
                mov edx, [min]
                mov [my_array], edx

                ; Выводим итоговый массив
                push [size]
                push my_array                                                                                      
                call write_array

                ; Завершаем алгоритм
                jmp finish

        ; Считвание массива
        read_array:
                push eax                                                                                       
                mov eax, esp
                push ecx                                                                                       
                push edx                                                                                       
                                                                                                               
                xor ecx, ecx
                mov edx, [ss:eax+8+0]

        read_array_loop:
                mov [point], eax                                                                       
                mov [tmp], edx                                                                                
                                                                                                               
                cmp ecx, [ss:eax+8+4]                                                                         
                jge end_read_array_loop                                                                           

                mov [i], ecx                                                                                  
                push ecx                                                                                       
                push elem_int                                                                               
                call [printf]                                                                                  
                                                                                                               
                push [tmp]                                                                                     
                push only_d                                                                                
                call [scanf]                                                                                   

                mov ecx, [i]                                                                                  
                inc ecx                                                                                       
                mov edx, [tmp]                                                                                
                add edx, 4                                                                                    
                mov eax, [point]                                                                       
                jmp read_array_loop                                                                              
                                                                                                               
        end_read_array_loop:                                                                                       
                sub eax, 8                                                                                    
                mov esp, eax                                                                                  

                pop edx                                                                                       
                pop ecx                                                                                       
                pop eax                                                                                       
                                                                                                               
        ret

        ; Вывод массива на экран
        write_array:                                                                                              

                push eax                                                                                       
                mov eax, esp                                                                                  
                push ecx                                                                                       
                push edx                                                                                       

                mov [point], eax                                                                       
                                                                                                               
                push bracket1                                                                            
                call [printf]                                                                                  
                                                                                                               
                mov  eax, [point]                                                                       
                                                                                                               
                xor ecx, ecx
                mov edx, [ss:eax+8+0]
                                                                                                               
        write_array_loop:
                mov [tmp], edx                                                                                
                mov [i], ecx                                                                                  
                                                                                                               
                cmp ecx, [ss:eax+8+4]
                jge end_write_array
                                                                                                               
                mov ecx, [edx]                                                                                
                push ecx                                                                                       
                push oneSymb                                                                                  
                call [printf]                                                                                  

                mov edx, [tmp]                                                                                
                add edx, 4                                                                                    
                mov ecx, [i]                                                                                  
                inc ecx                                                                                       
                mov eax, [point]                                                                       
                jmp write_array_loop                                                                              
                                                                                                               
        end_write_array:
                push bracket2                                                                            
                call [printf]                                                                                  

                mov eax, [point]                                                                       

                sub eax, 8                                                                                    
                mov esp, eax
                pop edx                                                                                       
                pop ecx                                                                                       
                pop eax                                                                                       
                                                                                                               
        ret                                                                                                    

        ; Поиск минимума в массиве
        find_minimum:
                push eax
                mov eax, esp
                push ecx
                push edx
                push ebx

                xor ecx, ecx
                mov edx, [ss:eax+8+0]

        find_minimum_loop:
                mov [point], eax
                mov [tmp], edx
                mov [i], ecx

                cmp ecx, [ss:eax+8+4]
                jge end_find_minimum_loop

 
                cmp ebx, [edx]
                jle find_minimum_loop2

                mov ebx, [edx]
                mov [min], ebx

        find_minimum_loop2:
                mov edx, [tmp]
                add edx, 4
                mov ecx, [i]
                inc ecx

                jmp find_minimum_loop

        end_find_minimum_loop:
                sub eax, 12
                mov esp, eax
                pop ebx
                pop edx
                pop ecx
                pop eax

        ret

        ; Смена местами минимального и первого элементов
        swap:
                push eax
                mov eax, esp
                push ecx
                push edx
                push ebx

                xor ecx, ecx ;ecx = 0
                mov edx, [ss:eax+8+0] 
                mov ebx, [edx]
                mov [first], ebx

                mov ebx, [min]
                mov [edx], ebx

        swap_loop:
                mov [point], eax
                mov [tmp], edx
                mov [i], ecx

                mov edx, [tmp]
                add edx, 4
                mov ecx, [i]
                inc ecx

                cmp ecx, [ss:eax+8+4]
                jge end_swap

                mov ebx, [min]
                cmp ebx, [edx]
                jne swap_loop

                mov ebx, [flag]
                cmp ebx, 1
                jne end_swap

                mov ebx, [first]
                mov [edx], ebx

                mov ebx, 2
                mov [flag], ebx

        end_swap:
                sub eax, 12
                mov esp, eax
                pop ebx
                pop edx
                pop ecx
                pop eax

        ret

        ; Конец алгоритма
        finish:                                                                                                
                call [getch]                                                                                   
                                                                                                               
                push NULL                                                                                      
                call ExitProcess                                                                                                          

                                                                                                               
section '.idata' data readable import                                                                          
                                                                                                               
        library kernel, 'kernel32.dll',\                                                                       
                msvcrt, 'msvcrt.dll'                                                                           
                                                                                                               
        import kernel,\                                                                                        
               ExitProcess, 'ExitProcess'                                                                      
                                                                                                               
        import msvcrt,\                                                                                        
               printf, 'printf',\                                                                              
               scanf, 'scanf',\                                                                                
               getch, '_getch'

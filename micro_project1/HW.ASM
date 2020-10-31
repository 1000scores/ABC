format PE console
 
include 'win32a.inc'
 
entry start                                                                                                    
 
section '.data' data readable writable
 
        write_string    db    'Write string please:',  10, 0 ; ?????? ?????????? ??????
 
        input_string    rd     100 ; ????? ????? ????????? ????????? ??????
 
        only_str        db    '%s',                        0
 
        str_size        dd     ? ; ?????? ??????
 
        only_d          db    '%d',                        0

        succes          db    'String is pallindrom',      0 ; ????? ??? ???????? ??????????

        notSucces       db    'String is not pallindrom',  0 ; ????? ??? ???????? ?? ??????????

        tmp             dd       ? ; ?????????? ??? ?????????? ???????? ?????????
 
        NULL = 0                                                                                               
 
 
section '.code' code readable executable
 
        start:                                                                                                 
                input_again:
                
                ; ?????? ????????????
                push write_string
                call [printf]
                
                ; ?????????? ??????
                push input_string
                push only_str
                call [scanf]
                
                ; ??????? ?????? ??????
                push input_string
                call cnt_size
                
                ; ????????? ?? ????????? ? ??????? ?????
                push input_string
                call check_pallindrom
                
                ; ?????????? ?????????
                jmp finish
 
        cnt_size:
                ; ?? ?????? ????????
                push eax                                                                                       
                mov eax, esp
                push ecx                                                                                       
                push edx
                push ebx
 
                xor ecx, ecx
                mov edx, [ss:eax+8+0]
 
        cnt_size_loop:
                mov ebx, 0

                cmp [edx], ebx
                je cnt_size_end
 
                inc ecx
                add edx, 1
                jmp cnt_size_loop
 
        cnt_size_end:
                sub eax, 12
                mov esp, eax
 
                mov [str_size], ecx

                pop ebx
                pop edx                                                                                       
                pop ecx                                                                                       
                pop eax                                                                                       
 
        ret
 
 
        check_pallindrom:
                push eax
                mov eax, esp
                mov [tmp], eax
                push ecx                                                                                       
                push edx
                push ebx
                                                                                                               
                mov ecx, [str_size]
                mov edx, [ss:eax+8+0]
                mov ebx, [ss:eax+8+0]

                add ebx, ecx
                sub ebx, 1
                xor ecx, ecx

        check_pallindrom_loop:

                cmp edx, ebx
                jge check_pallindrom_end_true

                ; ???????? ??????????????? ???????? ?? ?????????
                mov cl,  [edx]
                mov al, [ebx]
                cmp al, cl
                jne check_pallindrom_end_false

                add edx, 1
                sub ebx, 1
                inc ecx
                jmp check_pallindrom_loop
        
        ; ????????? ?????? ?????????!
        check_pallindrom_end_true:
                
                push succes
                call [printf]

                jmp finish_pallindrom
        
        ; ????????? ?????? ?? ?????????!
        check_pallindrom_end_false:
                push notSucces
                call [printf]

        finish_pallindrom:
                mov eax, [tmp]
                sub eax, 12
                mov esp, eax

                pop ebx
                pop edx                                                                                       
                pop ecx                                                                                       
                pop eax
                                                                                                               
        ret

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
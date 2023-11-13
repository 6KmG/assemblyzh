.MODEL medium 
.STACK 
.data
    errorMessage db "Exception!",0
    msg db "3 szam osszeszorzasra 0 es 20 kozott: ",0
    result db 10,"Az eredmeny: ",0

    ; "Változó" konstans
    var db ?
    

.CODE
exitProcess proc
    mov ah, 4Ch
    int 21h
exitProcess endp

printChar proc
    MOV AH, 2
    INT 21h
    ret
printChar endp

readChar proc
    mov ah, 01h
    int 21h
    mov dl, al

    ret
readChar endp 

print proc
    mov dl, [bx]
    cmp dl, 0
    je exit

    call printChar

    inc bx
    jmp print

    exit:
        mov dl, 0
        call printChar
        ret
print endp

printLine proc
    looping:
        mov dl, [bx]
        cmp dl, 0
        je exit

        call printChar

        inc bx
        jmp looping

    exit:
        mov dl, 10
        call printChar
        ret
printLine endp

read proc
    l1:
        call readChar
        cmp dl, " "
        je exit
        mov byte ptr [bx], dl 
        inc bx

    jmp l1

    exit: 
        mov byte ptr [bx], 0
        ret
read endp 

; csak pozitív számok
readInt proc
    mov cx, bx
    call read
    mov bx, cx

    xor ax, ax
    xor dx, dx

    l1:
        mov al, byte ptr [bx] ; "6" "5"

        cmp al, 0
        je exitcode

        cmp al, "9"
        jg error1

        cmp al, "0"
        jl error1

        sub ax, "0" ; 6 5
        add ax, dx  ; ax: 6 + 0 = 6 ax: 5 + 60 = 65
        mov cx, 10
        mul cx ; ax: 6 * 10 = 60

        mov dx, ax ; dx : 60

        inc bx ; byte ptr [bx] = "3"
        jmp l1


    exitcode:
        mov ax, dx
        mov bx, 10
        cwd
        div bx
        mov dx, ax
        ret

    error1:
        lea bx, errorMessage
        call print
        ret
readInt endp

printEvenChars proc
    inc bx
    test cx, 1
    jz l1
    dec cx
    l1:
        dec cx
        mov dl, byte ptr[bx]
        call printChar
        add bx, 2
        loop l1
    exit:
        ret
printEvenChars endp

printOddChars proc
    test cx, 1
    jz l1
    dec cx
    l1:
        dec cx
        mov dl, byte ptr[bx]
        call printChar
        add bx, 2
        loop l1
    exit:
        ret
printOddChars endp

printSpaceLine proc
    dec bx
    l1:
        inc bx
        mov dl, [bx]

        cmp dl, 0
        je exit

        cmp dl, " "
        jne false

        mov dl, 10

        false:
            call printChar
            jmp l1

    exit:
        mov dl, 0
        call printChar
        ret
printSpaceLine endp

printWithoutSpace proc
    dec bx
    l1:
        inc bx
        mov dl, [bx]

        cmp dl, 0
        je exit

        cmp dl, " "
        je l1

        call printChar
        jmp l1

    exit:
        mov dl, 0
        call printChar
        ret
printWithoutSpace endp

printUppercase proc
    dec bx
    l1:
        inc bx
        mov dl, [bx]

        cmp dl, 0
        je exit

        cmp dl, "a"
        jl false1

        cmp dl, "z"
        jg false2

        mov cl, "a"
        sub cl, "A"
        sub dl, cl

        false1:
        false2:
            call printChar
            jmp l1

    exit:
        mov dl, 0
        call printChar
        ret
printUppercase endp

printLowercase proc
    dec bx
    l1:
        inc bx
        mov dl, [bx]

        cmp dl, 0
        je exit

        cmp dl, "A"
        jl false1

        cmp dl, "Z"
        jg false2

        mov cl, "a"
        sub cl, "A"
        add dl, cl

        false1:
        false2:
            call printChar
            jmp l1

    exit:
        mov dl, 0
        call printChar
        ret
printLowercase endp

printReverse proc
    dec bx
    xor cl, cl
    l1:
        inc bx
        inc cl
        mov dl, [bx]
        cmp dl, 0
        jne l1

    l2:
        dec bx
        mov dl, [bx]

        cmp dl, 0
        je exit

        false1:
        false2:
            call printChar
            loop l2

    exit:
        mov dl, 0
        call printChar
        ret
printReverse endp

printInt proc
    xor cl, cl
    l1:
        mov ax, dx
        mov bl, 10
        div bl

        mov bl, ah
        xor bh, bh
        add bx, "0"
        push bx
        
        xor ah, ah
        mov dx, ax
        inc cl

        cmp dx, 0
        jg l1
        
    l2:
        pop dx
        call printChar
        loop l2

    exit:
        mov dl, 0
        call printChar
        ret
printInt endp

main proc
    mov ax, DGROUP
    mov ds, ax

    lea bx, msg
    call printLine

    ;code here
    lea bx, var
    call readInt
    push dx
    call readInt
    push dx
    call readInt

    pop ax
    mul dx

    pop dx
    mul dx

    push ax

    lea bx, result
    call print

    pop dx
    call printInt

    call exitProcess
main endp
END main
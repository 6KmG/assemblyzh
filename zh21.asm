.MODEL SMALL
.STACK 100H

.DATA
    errorMessage db "Jo ez",0
    result db 10,"Az eredmeny: ",0
    ;message DB " Hello, Word!$", 0 ; the message to draw
    color DB 0FH ; the color of the message (white)


    message db 100 dup(?)

    var db "0"

    row DB ? ; the row where to start drawing
    column DB ? ; the column where to start drawing


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
    mov dl, 32
    mov byte ptr [bx], dl
    inc bx
    xor dl, dl
    l1:
        call readChar
        cmp dl, " "
        je exit
        mov byte ptr [bx], dl 
        inc bx

    jmp l1

    exit: 
        mov byte ptr [bx], "$"
        inc bx
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

main PROC
    MOV AX, @DATA
    MOV DS, AX

    lea bx, var
    call readInt
    lea bx, row
    mov byte ptr [bx], dl
    xor dx, dx

    lea bx, var
    call readInt
    lea bx, column
    mov byte ptr [bx], dl
    xor dx, dx

    lea bx, message
    call read

    ; set video mode to 13h (320x200 with 256 colors)
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    ; draw the message
    LEA SI, message ; load the address of the message into SI
printLoop:
    MOV AL, [SI] ; load the current character into AL
    CMP AL, '$' ; check if we've reached the end of the string
    JE done
    MOV AH, 0EH ; function to write a character in teletype mode
    MOV BH, 0 ; page number
    MOV BL, color ; color of the character
    INT 10H
    INC column ; move the cursor to the next column
    MOV AH, 02H ; function to set the cursor position
    MOV DH, row ; row
    MOV DL, column ; column
    INT 10H
    INC SI ; move to the next character
    JMP printLoop
done:

    ; wait for a key press
    MOV AH, 00H
    INT 16H

    ; return to text mode
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; return to DOS
    MOV AH, 4CH
    INT 21H
main ENDP
END main

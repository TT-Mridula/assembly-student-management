.MODEL SMALL                                                                   .MODEL SMALL
.STACK 100H

.DATA

max_students DW 5
subjects DW 5


student_count dw 0
student_id dw 0,0,0,0,0
digit_count db 0

msg_invalid_id db 13,10,'ID too large! Use max 5 digits.$'


student_name db 100 dup('$')

marks db 25 dup(0)
total_marks dw 0,0,0,0,0
average dw 0,0,0,0,0
final_marks dw 0,0,0,0,0
grades db 'f','f','f','f','f'
classes_attended db 0,0,0,0,0
attendance_bonus dw 0,0,0,0,0

rank_indices dw 0,0,0,0,0

highest_marks dw 0
lowest_marks dw 100
highest_student dw 0
lowest_student dw 0
class_average dw 0
class_total dw 0
pass_count dw 0
fail_count dw 0

menu db 13,10,'1. Add Student'
db 13,10,'2. Enter Marks'
db 13,10,'3. Enter Attendance'
db 13,10,'4. Generate Report Card'
db 13,10,'5. Show Class Statistics'
db 13,10,'6. Show Student Rankings'
db 13,10,'7. Search Student'
db 13,10,'8. Edit Student'
db 13,10,'9. Delete Student'
db 13,10,'0. Exit'
db 13,10,'Choice: $'


msg_id DB 13,10,'Enter Student ID: $'
msg_name DB 13,10,'Enter Student Name: $'
msg_mark DB 13,10,'Subject $'
msg_colon DB ': $'
msg_att DB 13,10,'Classes Attended (0-10): $'
msg_added DB 13,10,'Added successfully!$'
msg_updated DB 13,10,'Updated successfully!$'
msg_notfound DB 13,10,'Student not found!$'
msg_nostd DB 13,10,'No students!$'
msg_found DB 13,10,'Student found!$'

msg_report DB 13,10,'=== REPORT CARD ===$'
msg_id_dis DB 13,10,'ID: $'
msg_name_dis DB 13,10,'Name: $'
msg_total_dis DB 13,10,'Total: $'
msg_avg_dis DB 13,10,'Average: $'
msg_grade_dis DB 13,10,'Grade: $'
msg_att_dis DB 13,10,'Attendance: $'
msg_outof DB '/10$'
msg_bonus_dis DB 13,10,'Bonus: $'
msg_final_dis DB 13,10,'Final Score: $'

msg_rank DB 13,10,'=== STUDENT RANKINGS ===$'
msg_ranknum DB 13,10,'Rank $'
msg_pipe DB ' | $'

msg_stat DB 13,10,'=== CLASS STATISTICS ===$'
msg_calc DB 13,10,'Calculating all data...$'
msg_ready DB 13,10,'Results ready!$'
msg_totalstd DB 13,10,'Total Students: $'
msg_classtotal DB 13,10,'Class Total: $'
msg_classavg DB 13,10,'Class Average: $'
msg_highest DB 13,10,'Highest: $'
msg_lowest DB 13,10,'Lowest: $'
msg_by DB ' by ID: $'
msg_pass DB 13,10,'Passed: $'
msg_fail DB 13,10,'Failed: $' 
msg_invalid_mark DB 13,10,'Invalid mark! Enter 0 - 100 only.$' 
msg_invalid_id1 DB 13,10,'Invalid ID! Use digits only (0-9).$'
msg_invalid_name1 DB 13,10,'Invalid Name! Use letters and space only.$'




newline db 13,10,'$'
temp_id dw ?
found_idx dw ?
subj_num db ?

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX


menu_loop:
    lea dx,menu
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h
    sub al,'0'

    cmp al,1
    je add_std
    cmp al,2
    je enter_marks
    cmp al,3
    je enter_att
    cmp al,4
    je report
    cmp al,5
    je stats
    cmp al,6
    je rankings
    cmp al,7
    je search_std
    cmp al,8
    je edit_std
    cmp al,9
    je delete_std
    cmp al,0
    je exit_p

    jmp menu_loop
add_std:
    mov ax,student_count
    cmp ax,5        ; max student=5
    jge menu_loop


    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num

    mov bx,student_count
    add bx,bx
    mov student_id[bx],ax

    lea dx,msg_name
    mov ah,09h
    int 21h

    mov bx,student_count
    mov ax,20
    mul bx
    mov si,ax
    lea di,student_name[si]
    call read_str

    inc student_count

    lea dx,msg_added
    mov ah,09h
    int 21h
    jmp menu_loop

enter_marks:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    mov ax,found_idx
    mov bx,5
    mul bx

    mov si,ax

    mov cx,5

    mov subj_num,1

mark_loop:
    lea dx,msg_mark
    mov ah,09h
    int 21h

    mov dl,subj_num
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_colon
    mov ah,09h
    int 21h

get_mark:
    call read_num
    cmp ax,100
    jg invalid_mark
    cmp ax,0
    jl invalid_mark

    mov marks[si],al
    inc si
    inc subj_num
    loop mark_loop
    jmp mark_done

invalid_mark:
    lea dx,msg_invalid_mark
    mov ah,09h
    int 21h
    jmp get_mark

mark_done:
    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

enter_att:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_att
    mov ah,09h
    int 21h
    call read_num

    mov bx,found_idx
    mov classes_attended[bx],al

    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

report:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    call calc_one

    lea dx,msg_report
    mov ah,09h
    int 21h

    lea dx,msg_id_dis
    mov ah,09h
    int 21h
    mov ax,temp_id
    call print_num

    lea dx,msg_name_dis
    mov ah,09h
    int 21h
    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h

    mov ax,found_idx
    mov bx,subjects
    mul bx
    mov si,ax
    mov cx,5
    mov subj_num,1

report_marks:
    lea dx,msg_mark
    mov ah,09h
    int 21h

    mov dl,subj_num
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_colon
    mov ah,09h
    int 21h

    mov al,marks[si]
    mov ah,0
    call print_num

    inc si
    inc subj_num
    loop report_marks

    mov bx,found_idx
    add bx,bx

    lea dx,msg_total_dis
    mov ah,09h
    int 21h
    mov ax,total_marks[bx]
    call print_num

    lea dx,msg_avg_dis
    mov ah,09h
    int 21h
    mov ax,average[bx]
    call print_num

    ;REARRANGED: Print Attendance First
    lea dx,msg_att_dis
    mov ah,09h
    int 21h
    mov bx,found_idx
    mov al,classes_attended[bx]
    mov ah,0
    call print_num

    lea dx,msg_outof
    mov ah,09h
    int 21h

    ;Then Bonus 
    mov bx,found_idx
    add bx,bx
    lea dx,msg_bonus_dis
    mov ah,09h
    int 21h
    mov ax,attendance_bonus[bx]
    call print_num

    ;Then Final Score 
    lea dx,msg_final_dis
    mov ah,09h
    int 21h
    mov ax,final_marks[bx]
    call print_num

    ;THEN GRADE (Moved to the end) 
    lea dx,msg_grade_dis
    mov ah,09h
    int 21h
    mov bx,found_idx
    mov dl,grades[bx]
    mov ah,02h
    int 21h

    lea dx,newline
    mov ah,09h
    int 21h
    jmp menu_loop

stats:
    cmp student_count,0
    je no_std

    lea dx,msg_stat
    mov ah,09h
    int 21h

    lea dx,msg_calc
    mov ah,09h
    int 21h

    call update_all_data

    mov highest_marks,0
    mov lowest_marks,100
    mov class_total,0
    mov pass_count,0
    mov fail_count,0
    mov highest_student,0
    mov lowest_student,0

    mov cx,student_count
    mov bx,0

calc_loop:
    push cx
    push bx

    mov si,bx
    add si,si
    mov ax,final_marks[si]
    add class_total,ax

    cmp ax,highest_marks
    jle chk_low
    mov highest_marks,ax
    mov highest_student,bx

chk_low:
    cmp ax,lowest_marks
    jge chk_pass
    mov lowest_marks,ax
    mov lowest_student,bx

chk_pass:
    cmp ax,40
    jge incr_pass
    inc fail_count
    jmp next_std

incr_pass:
    inc pass_count

next_std:
    pop bx
    pop cx
    inc bx
    loop calc_loop

    mov ax,class_total
    mov dx,0
    mov bx,student_count
    div bx
    mov class_average,ax

    lea dx,msg_ready
    mov ah,09h
    int 21h

    lea dx,msg_totalstd
    mov ah,09h
    int 21h
    mov ax,student_count
    call print_num

    lea dx,msg_classtotal
    mov ah,09h
    int 21h
    mov ax,class_total
    call print_num

    lea dx,msg_classavg
    mov ah,09h
    int 21h
    mov ax,class_average
    call print_num

    lea dx,msg_highest
    mov ah,09h
    int 21h
    mov ax,highest_marks
    call print_num

    lea dx,msg_by
    mov ah,09h
    int 21h
    mov bx,highest_student
    add bx,bx
    mov ax,student_id[bx]
    call print_num

    lea dx,msg_lowest
    mov ah,09h
    int 21h
    mov ax,lowest_marks
    call print_num

    lea dx,msg_by
    mov ah,09h
    int 21h
    mov bx,lowest_student
    add bx,bx
    mov ax,student_id[bx]
    call print_num

    lea dx,msg_pass
    mov ah,09h
    int 21h
    mov ax,pass_count
    call print_num

    lea dx,msg_fail
    mov ah,09h
    int 21h
    mov ax,fail_count
    call print_num

    lea dx,newline
    mov ah,09h
    int 21h
    jmp menu_loop

rankings:
    cmp student_count,0
    je no_std

    call update_all_data

    mov cx,student_count
    mov bx,0
    mov si,0
init_idx_loop:
    mov rank_indices[si],bx
    add si,2
    inc bx
    loop init_idx_loop

    cmp student_count,1
    jle print_ranks

    mov cx,student_count
    dec cx

sort_outer:
    push cx
    mov si,0

sort_inner:
    mov bx,rank_indices[si]
    add bx,bx
    mov ax,final_marks[bx]

    mov di,rank_indices[si+2]
    add di,di
    mov dx,final_marks[di]

    cmp ax,dx
    jge no_swap

    mov bx,rank_indices[si]
    mov dx,rank_indices[si+2]
    mov rank_indices[si],dx
    mov rank_indices[si+2],bx

no_swap:
    add si,2
    loop sort_inner

    pop cx
    loop sort_outer

print_ranks:
    lea dx,msg_rank
    mov ah,09h
    int 21h

    mov cx,student_count
    mov si,0
    mov bl,1

print_rank_loop:
    push cx
    push bx

    mov di,rank_indices[si]

    lea dx,msg_ranknum
    mov ah,09h
    int 21h

    pop bx
    push bx
    mov dl,bl
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,di
    add ax,ax
    mov si,ax
    mov ax,student_id[si]
    call print_num
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,20
    mul di
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,di
    add ax,ax
    mov si,ax
    mov ax,final_marks[si]
    call print_num
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov dl,grades[di]
    mov ah,02h
    int 21h
    pop si

    lea dx,newline
    mov ah,09h
    int 21h

    add si,2
    pop bx
    inc bl
    pop cx
    dec cx
    jnz print_rank_loop
    jmp menu_loop

search_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_found
    mov ah,09h
    int 21h

    lea dx,msg_id_dis
    mov ah,09h
    int 21h
    mov ax,temp_id
    call print_num

    lea dx,msg_name_dis
    mov ah,09h
    int 21h
    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h
    jmp menu_loop
edit_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num

    mov bx,found_idx
    add bx,bx
    mov student_id[bx],ax

    lea dx,msg_name
    mov ah,09h
    int 21h

    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea di,student_name[si]
    call read_str

    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

delete_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    mov bx,found_idx

del_loop:
    mov cx,student_count
    dec cx
    cmp bx,cx
    jge del_done

    mov si,bx
    add si,si
    mov di,si
    add di,2
    mov ax,student_id[di]
    mov student_id[si],ax

    push bx
    mov ax,20
    mul bx
    mov si,ax
    mov di,ax
    add di,20
    mov cx,20
shift_name:
    mov al,student_name[di]
    mov student_name[si],al
    inc si
    inc di
    loop shift_name
    pop bx

    inc bx
    jmp del_loop

del_done:
    dec student_count
    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

no_std:
    lea dx,msg_nostd
    mov ah,09h
    int 21h
    jmp menu_loop

not_found:
    lea dx,msg_notfound
    mov ah,09h
    int 21h
    jmp menu_loop

exit_p:
    mov ah,4ch
    int 21h

main endp

update_all_data proc
    push ax
    push bx
    push cx
    push dx

    cmp student_count,0
    je update_ret

    mov cx,student_count
    mov bx,0

update_loop:
    push cx
    push bx
    mov found_idx,bx
    call calc_one
    pop bx
    pop cx
    inc bx
    loop update_loop

update_ret:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_all_data endp

calc_one proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx,found_idx
    mov ax,subjects
    mul bx
    mov si,ax

    mov cx,5
    mov ax,0


calc_sum:
    push bx
    mov bl,marks[si]
    mov bh,0
    add ax,bx
    pop bx
    inc si
    loop calc_sum

    mov bx,found_idx
    add bx,bx
    mov total_marks[bx],ax

    mov dl, 5 
    div dl
    mov ah,0
    mov average[bx],ax

    mov bx,found_idx
    mov al,classes_attended[bx]
    mov ah,0

    cmp al,8
    jge one_full
    cmp al,5
    jge one_half
    mov ax,0
    jmp one_store

one_half:
    mov ax,2
    jmp one_store

one_full:
    mov ax,5

one_store:
    add bx,bx
    mov attendance_bonus[bx],ax

    mov dx,average[bx]
    add dx,ax
    mov final_marks[bx],dx

    mov ax, dx        

    mov bx,found_idx
    call get_grade
    mov grades[bx],al

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calc_one endp

find_std proc
    push cx
    push bx

    mov cx,student_count
    mov bx,0

find_loop:
    push bx
    add bx,bx
    mov ax,student_id[bx]
    pop bx
    cmp ax,temp_id
    je found
    inc bx
    loop find_loop

    mov found_idx,-1
    jmp find_end

found:
    mov found_idx,bx

find_end:
    pop bx
    pop cx
    ret
find_std endp

READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

INPUT_AGAIN:
    MOV BX,0
    MOV digit_count,0

READ_LOOP:
    MOV AH,01H
    INT 21H

    CMP AL,13          
    JE END_READ

    
    CMP AL,'0'
    JB INVALID_INPUT
    CMP AL,'9'
    JA INVALID_INPUT
    

    INC digit_count
    CMP digit_count,5
    JA INVALID_INPUT

    SUB AL,'0'
    MOV AH,0
    MOV CX,AX

    MOV AX,BX
    MOV DX,10
    MUL DX
    ADD AX,CX
    MOV BX,AX

    JMP READ_LOOP

INVALID_INPUT:
    LEA DX,msg_invalid_id1   
    MOV AH,09H
    INT 21H
    JMP INPUT_AGAIN         

END_READ:
    MOV AX,BX

    POP DX
    POP CX
    POP BX
    RET
READ_NUM ENDP



print_num proc
    push ax
    push bx
    push cx
    push dx

    mov bx,10
    mov cx,0

pn1:
    mov dx,0
    div bx
    push dx
    inc cx
    cmp ax,0
    jne pn1

pn2:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop pn2

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

read_str proc
    push ax
    push di

    mov cx,0            

read_char:
    mov ah,01h
    int 21h

    cmp al,13           
    je end_name

    
    cmp al,'A'
    jb invalid_name
    cmp al,'Z'
    jbe store_char

    cmp al,'a'
    jb check_space
    cmp al,'z'
    jbe store_char

check_space:
    cmp al,' '
    je store_char
    jmp invalid_name
    

store_char:
    mov [di],al
    inc di
    inc cx
    cmp cx,19            
    jae end_name
    jmp read_char

invalid_name:
    lea dx,msg_invalid_name1
    mov ah,09h
    int 21h
    jmp read_char

end_name:
    mov [di],'$'

    pop di
    pop ax
    ret
read_str endp


get_grade proc
    cmp ax,80
    jge grd_a
    cmp ax,60
    jge grd_b
    cmp ax,40
    jge grd_c
    mov al,'F'
    ret
grd_a:
    mov al,'A'
    ret
grd_b:
    mov al,'B'
    ret
grd_c:
    mov al,'C'
    ret
get_grade endp

END MAIN

.STACK 100H

.DATA

max_students DW 5
subjects DW 5


student_count dw 0
student_id dw 0,0,0,0,0
digit_count db 0

msg_invalid_id db 13,10,'ID too large! Use max 5 digits.$'


student_name db 100 dup('$')

marks db 25 dup(0)
total_marks dw 0,0,0,0,0
average dw 0,0,0,0,0
final_marks dw 0,0,0,0,0
grades db 'f','f','f','f','f'
classes_attended db 0,0,0,0,0
attendance_bonus dw 0,0,0,0,0

rank_indices dw 0,0,0,0,0

highest_marks dw 0
lowest_marks dw 100
highest_student dw 0
lowest_student dw 0
class_average dw 0
class_total dw 0
pass_count dw 0
fail_count dw 0

menu db 13,10,'1. Add Student'
db 13,10,'2. Enter Marks'
db 13,10,'3. Enter Attendance'
db 13,10,'4. Generate Report Card'
db 13,10,'5. Show Class Statistics'
db 13,10,'6. Show Student Rankings'
db 13,10,'7. Search Student'
db 13,10,'8. Edit Student'
db 13,10,'9. Delete Student'
db 13,10,'0. Exit'
db 13,10,'Choice: $'


msg_id DB 13,10,'Enter Student ID: $'
msg_name DB 13,10,'Enter Student Name: $'
msg_mark DB 13,10,'Subject $'
msg_colon DB ': $'
msg_att DB 13,10,'Classes Attended (0-10): $'
msg_added DB 13,10,'Added successfully!$'
msg_updated DB 13,10,'Updated successfully!$'
msg_notfound DB 13,10,'Student not found!$'
msg_nostd DB 13,10,'No students!$'
msg_found DB 13,10,'Student found!$'

msg_report DB 13,10,'=== REPORT CARD ===$'
msg_id_dis DB 13,10,'ID: $'
msg_name_dis DB 13,10,'Name: $'
msg_total_dis DB 13,10,'Total: $'
msg_avg_dis DB 13,10,'Average: $'
msg_grade_dis DB 13,10,'Grade: $'
msg_att_dis DB 13,10,'Attendance: $'
msg_outof DB '/10$'
msg_bonus_dis DB 13,10,'Bonus: $'
msg_final_dis DB 13,10,'Final Score: $'

msg_rank DB 13,10,'=== STUDENT RANKINGS ===$'
msg_ranknum DB 13,10,'Rank $'
msg_pipe DB ' | $'

msg_stat DB 13,10,'=== CLASS STATISTICS ===$'
msg_calc DB 13,10,'Calculating all data...$'
msg_ready DB 13,10,'Results ready!$'
msg_totalstd DB 13,10,'Total Students: $'
msg_classtotal DB 13,10,'Class Total: $'
msg_classavg DB 13,10,'Class Average: $'
msg_highest DB 13,10,'Highest: $'
msg_lowest DB 13,10,'Lowest: $'
msg_by DB ' by ID: $'
msg_pass DB 13,10,'Passed: $'
msg_fail DB 13,10,'Failed: $' 
msg_invalid_mark DB 13,10,'Invalid mark! Enter 0 - 100 only.$' 
msg_invalid_id1 DB 13,10,'Invalid ID! Use digits only (0-9).$'
msg_invalid_name1 DB 13,10,'Invalid Name! Use letters and space only.$'




newline db 13,10,'$'
temp_id dw ?
found_idx dw ?
subj_num db ?

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX


menu_loop:
    lea dx,menu
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h
    sub al,'0'

    cmp al,1
    je add_std
    cmp al,2
    je enter_marks
    cmp al,3
    je enter_att
    cmp al,4
    je report
    cmp al,5
    je stats
    cmp al,6
    je rankings
    cmp al,7
    je search_std
    cmp al,8
    je edit_std
    cmp al,9
    je delete_std
    cmp al,0
    je exit_p

    jmp menu_loop
add_std:
    mov ax,student_count
    cmp ax,5        ; max student=5
    jge menu_loop


    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num

    mov bx,student_count
    add bx,bx
    mov student_id[bx],ax

    lea dx,msg_name
    mov ah,09h
    int 21h

    mov bx,student_count
    mov ax,20
    mul bx
    mov si,ax
    lea di,student_name[si]
    call read_str

    inc student_count

    lea dx,msg_added
    mov ah,09h
    int 21h
    jmp menu_loop

enter_marks:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    mov ax,found_idx
    mov bx,5
    mul bx

    mov si,ax

    mov cx,5

    mov subj_num,1

mark_loop:
    lea dx,msg_mark
    mov ah,09h
    int 21h

    mov dl,subj_num
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_colon
    mov ah,09h
    int 21h

get_mark:
    call read_num
    cmp ax,100
    jg invalid_mark
    cmp ax,0
    jl invalid_mark

    mov marks[si],al
    inc si
    inc subj_num
    loop mark_loop
    jmp mark_done

invalid_mark:
    lea dx,msg_invalid_mark
    mov ah,09h
    int 21h
    jmp get_mark

mark_done:
    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

enter_att:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_att
    mov ah,09h
    int 21h
    call read_num

    mov bx,found_idx
    mov classes_attended[bx],al

    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

report:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    call calc_one

    lea dx,msg_report
    mov ah,09h
    int 21h

    lea dx,msg_id_dis
    mov ah,09h
    int 21h
    mov ax,temp_id
    call print_num

    lea dx,msg_name_dis
    mov ah,09h
    int 21h
    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h

    mov ax,found_idx
    mov bx,subjects
    mul bx
    mov si,ax
    mov cx,5
    mov subj_num,1

report_marks:
    lea dx,msg_mark
    mov ah,09h
    int 21h

    mov dl,subj_num
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_colon
    mov ah,09h
    int 21h

    mov al,marks[si]
    mov ah,0
    call print_num

    inc si
    inc subj_num
    loop report_marks

    mov bx,found_idx
    add bx,bx

    lea dx,msg_total_dis
    mov ah,09h
    int 21h
    mov ax,total_marks[bx]
    call print_num

    lea dx,msg_avg_dis
    mov ah,09h
    int 21h
    mov ax,average[bx]
    call print_num

    lea dx,msg_grade_dis
    mov ah,09h
    int 21h
    mov bx,found_idx
    mov dl,grades[bx]
    mov ah,02h
    int 21h

    lea dx,msg_att_dis
    mov ah,09h
    int 21h
    mov al,classes_attended[bx]
    mov ah,0
    call print_num

    lea dx,msg_outof
    mov ah,09h
    int 21h

    add bx,bx
    lea dx,msg_bonus_dis
    mov ah,09h
    int 21h
    mov ax,attendance_bonus[bx]
    call print_num

    lea dx,msg_final_dis
    mov ah,09h
    int 21h
    mov ax,final_marks[bx]
    call print_num

    lea dx,newline
    mov ah,09h
    int 21h
    jmp menu_loop
stats:
    cmp student_count,0
    je no_std

    lea dx,msg_stat
    mov ah,09h
    int 21h

    lea dx,msg_calc
    mov ah,09h
    int 21h

    call update_all_data

    mov highest_marks,0
    mov lowest_marks,100
    mov class_total,0
    mov pass_count,0
    mov fail_count,0
    mov highest_student,0
    mov lowest_student,0

    mov cx,student_count
    mov bx,0

calc_loop:
    push cx
    push bx

    mov si,bx
    add si,si
    mov ax,final_marks[si]
    add class_total,ax

    cmp ax,highest_marks
    jle chk_low
    mov highest_marks,ax
    mov highest_student,bx

chk_low:
    cmp ax,lowest_marks
    jge chk_pass
    mov lowest_marks,ax
    mov lowest_student,bx

chk_pass:
    cmp ax,40
    jge incr_pass
    inc fail_count
    jmp next_std

incr_pass:
    inc pass_count

next_std:
    pop bx
    pop cx
    inc bx
    loop calc_loop

    mov ax,class_total
    mov dx,0
    mov bx,student_count
    div bx
    mov class_average,ax

    lea dx,msg_ready
    mov ah,09h
    int 21h

    lea dx,msg_totalstd
    mov ah,09h
    int 21h
    mov ax,student_count
    call print_num

    lea dx,msg_classtotal
    mov ah,09h
    int 21h
    mov ax,class_total
    call print_num

    lea dx,msg_classavg
    mov ah,09h
    int 21h
    mov ax,class_average
    call print_num

    lea dx,msg_highest
    mov ah,09h
    int 21h
    mov ax,highest_marks
    call print_num

    lea dx,msg_by
    mov ah,09h
    int 21h
    mov bx,highest_student
    add bx,bx
    mov ax,student_id[bx]
    call print_num

    lea dx,msg_lowest
    mov ah,09h
    int 21h
    mov ax,lowest_marks
    call print_num

    lea dx,msg_by
    mov ah,09h
    int 21h
    mov bx,lowest_student
    add bx,bx
    mov ax,student_id[bx]
    call print_num

    lea dx,msg_pass
    mov ah,09h
    int 21h
    mov ax,pass_count
    call print_num

    lea dx,msg_fail
    mov ah,09h
    int 21h
    mov ax,fail_count
    call print_num

    lea dx,newline
    mov ah,09h
    int 21h
    jmp menu_loop

rankings:
    cmp student_count,0
    je no_std

    call update_all_data

    mov cx,student_count
    mov bx,0
    mov si,0
init_idx_loop:
    mov rank_indices[si],bx
    add si,2
    inc bx
    loop init_idx_loop

    cmp student_count,1
    jle print_ranks

    mov cx,student_count
    dec cx

sort_outer:
    push cx
    mov si,0

sort_inner:
    mov bx,rank_indices[si]
    add bx,bx
    mov ax,final_marks[bx]

    mov di,rank_indices[si+2]
    add di,di
    mov dx,final_marks[di]

    cmp ax,dx
    jge no_swap

    mov bx,rank_indices[si]
    mov dx,rank_indices[si+2]
    mov rank_indices[si],dx
    mov rank_indices[si+2],bx

no_swap:
    add si,2
    loop sort_inner

    pop cx
    loop sort_outer

print_ranks:
    lea dx,msg_rank
    mov ah,09h
    int 21h

    mov cx,student_count
    mov si,0
    mov bl,1

print_rank_loop:
    push cx
    push bx

    mov di,rank_indices[si]

    lea dx,msg_ranknum
    mov ah,09h
    int 21h

    pop bx
    push bx
    mov dl,bl
    add dl,'0'
    mov ah,02h
    int 21h

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,di
    add ax,ax
    mov si,ax
    mov ax,student_id[si]
    call print_num
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,20
    mul di
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov ax,di
    add ax,ax
    mov si,ax
    mov ax,final_marks[si]
    call print_num
    pop si

    lea dx,msg_pipe
    mov ah,09h
    int 21h

    push si
    mov dl,grades[di]
    mov ah,02h
    int 21h
    pop si

    lea dx,newline
    mov ah,09h
    int 21h

    add si,2
    pop bx
    inc bl
    pop cx
    dec cx
    jnz print_rank_loop
    jmp menu_loop

search_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_found
    mov ah,09h
    int 21h

    lea dx,msg_id_dis
    mov ah,09h
    int 21h
    mov ax,temp_id
    call print_num

    lea dx,msg_name_dis
    mov ah,09h
    int 21h
    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea dx,student_name[si]
    mov ah,09h
    int 21h
    jmp menu_loop
edit_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num

    mov bx,found_idx
    add bx,bx
    mov student_id[bx],ax

    lea dx,msg_name
    mov ah,09h
    int 21h

    mov ax,found_idx
    mov bx,20
    mul bx
    mov si,ax
    lea di,student_name[si]
    call read_str

    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

delete_std:
    cmp student_count,0
    je no_std

    lea dx,msg_id
    mov ah,09h
    int 21h
    call read_num
    mov temp_id,ax

    call find_std
    cmp found_idx,-1
    je not_found

    mov bx,found_idx

del_loop:
    mov cx,student_count
    dec cx
    cmp bx,cx
    jge del_done

    mov si,bx
    add si,si
    mov di,si
    add di,2
    mov ax,student_id[di]
    mov student_id[si],ax

    push bx
    mov ax,20
    mul bx
    mov si,ax
    mov di,ax
    add di,20
    mov cx,20
shift_name:
    mov al,student_name[di]
    mov student_name[si],al
    inc si
    inc di
    loop shift_name
    pop bx

    inc bx
    jmp del_loop

del_done:
    dec student_count
    lea dx,msg_updated
    mov ah,09h
    int 21h
    jmp menu_loop

no_std:
    lea dx,msg_nostd
    mov ah,09h
    int 21h
    jmp menu_loop

not_found:
    lea dx,msg_notfound
    mov ah,09h
    int 21h
    jmp menu_loop

exit_p:
    mov ah,4ch
    int 21h

main endp

update_all_data proc
    push ax
    push bx
    push cx
    push dx

    cmp student_count,0
    je update_ret

    mov cx,student_count
    mov bx,0

update_loop:
    push cx
    push bx
    mov found_idx,bx
    call calc_one
    pop bx
    pop cx
    inc bx
    loop update_loop

update_ret:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_all_data endp

calc_one proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx,found_idx
    mov ax,subjects
    mul bx
    mov si,ax

    mov cx,5
    mov ax,0


calc_sum:
    push bx
    mov bl,marks[si]
    mov bh,0
    add ax,bx
    pop bx
    inc si
    loop calc_sum

    mov bx,found_idx
    add bx,bx
    mov total_marks[bx],ax

    mov dl, 5 
    div dl
    mov ah,0
    mov average[bx],ax

    mov bx,found_idx
    mov al,classes_attended[bx]
    mov ah,0

    cmp al,8
    jge one_full
    cmp al,5
    jge one_half
    mov ax,0
    jmp one_store

one_half:
    mov ax,2
    jmp one_store

one_full:
    mov ax,5

one_store:
    add bx,bx
    mov attendance_bonus[bx],ax

    mov dx,average[bx]
    add dx,ax
    mov final_marks[bx],dx

    mov ax,average[bx]
    mov bx,found_idx
    call get_grade
    mov grades[bx],al

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calc_one endp

find_std proc
    push cx
    push bx

    mov cx,student_count
    mov bx,0

find_loop:
    push bx
    add bx,bx
    mov ax,student_id[bx]
    pop bx
    cmp ax,temp_id
    je found
    inc bx
    loop find_loop

    mov found_idx,-1
    jmp find_end

found:
    mov found_idx,bx

find_end:
    pop bx
    pop cx
    ret
find_std endp

READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

INPUT_AGAIN:
    MOV BX,0
    MOV digit_count,0

READ_LOOP:
    MOV AH,01H
    INT 21H

    CMP AL,13          
    JE END_READ

    
    CMP AL,'0'
    JB INVALID_INPUT
    CMP AL,'9'
    JA INVALID_INPUT
    

    INC digit_count
    CMP digit_count,5
    JA INVALID_INPUT

    SUB AL,'0'
    MOV AH,0
    MOV CX,AX

    MOV AX,BX
    MOV DX,10
    MUL DX
    ADD AX,CX
    MOV BX,AX

    JMP READ_LOOP

INVALID_INPUT:
    LEA DX,msg_invalid_id1   
    MOV AH,09H
    INT 21H
    JMP INPUT_AGAIN         

END_READ:
    MOV AX,BX

    POP DX
    POP CX
    POP BX
    RET
READ_NUM ENDP



print_num proc
    push ax
    push bx
    push cx
    push dx

    mov bx,10
    mov cx,0

pn1:
    mov dx,0
    div bx
    push dx
    inc cx
    cmp ax,0
    jne pn1

pn2:
    pop dx
    add dl,'0'
    mov ah,02h
    int 21h
    loop pn2

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

read_str proc
    push ax
    push di

    mov cx,0            

read_char:
    mov ah,01h
    int 21h

    cmp al,13           
    je end_name

    
    cmp al,'A'
    jb invalid_name
    cmp al,'Z'
    jbe store_char

    cmp al,'a'
    jb check_space
    cmp al,'z'
    jbe store_char

check_space:
    cmp al,' '
    je store_char
    jmp invalid_name
    

store_char:
    mov [di],al
    inc di
    inc cx
    cmp cx,19           
    jae end_name
    jmp read_char

invalid_name:
    lea dx,msg_invalid_name1
    mov ah,09h
    int 21h
    jmp read_char

end_name:
    mov [di],'$'

    pop di
    pop ax
    ret
read_str endp


get_grade proc
    cmp ax,80
    jge grd_a
    cmp ax,60
    jge grd_b
    cmp ax,40
    jge grd_c
    mov al,'F'
    ret
grd_a:
    mov al,'A'
    ret
grd_b:
    mov al,'B'
    ret
grd_c:
    mov al,'C'
    ret
get_grade endp

END MAIN


.MODEL SMALL                        
.STACK 100H
.DATA 
    nextLine DB 13, 10, "$"
    
    generateGrid DB "_|_|_", 13, 10
                 DB "_|_|_", 13, 10
                 DB "_|_|_", 13, 10, "$"    
                  
    positionArray DB 9 DUP(?)  
    
    winner DB 0 
    playerNum DB "1$" 
    
    gameOverText DB "Game Over !!! ", 13, 10, "$"    
    startingText DB "Welcome To Tic Tac Toe", 13, 10, "$" 
    endingText DB "Final result",13,10,"$"
    playerText DB "PLAYER $"   
    declareWinner DB " WON$"   
    positionText DB "Take a position (1-9): $"    
    
    
    
    
.CODE
    MAIN PROC  
        
        MOV AX, @DATA
        MOV DS, AX 
        
        
        CALL set_positionArray_grid   ;goes to set_positionArray (without following any conditions) to set the positionArray and grid 
        
        MOV AH,9
        LEA DX, startingText
        INT 21H      
                
    controlGame: 
        ; for showing the grid, output, player number, turns on screen until the game ends with a winner 
        MOV AH,9 
        
        LEA DX,nextLine 
        INT 21H   
        
        
        LEA DX, nextLine
        INT 21H
                              
           
        
        LEA DX, generateGrid 
        INT 21H
            
        
        LEA DX,nextLine  
        INT 21H 

        LEA DX, playerText
        INT 21H 
        
        
        LEA DX, playerNum 
        INT 21H 
          
        
        LEA DX,nextLine
        INT 21H 
           
        
        LEA DX,positionText
        INT 21H    
          
                            
        
        MOV AH,1 ; take user input (1 digit)
        INT 21H   
       
                           
        ; convert ascii to decimal                   
        SUB AL,49 ; considers input starting from 1             
        MOV BH,0  
        MOV BL,AL                                 
                                      
    CALL update_positionArray  ;goes to update_positionArray <without following any conditions> to set the turn of player 1 (X) and player 2 (O)                                   
                                                          

    CALL set_row  ;goes to set row values 
    CALL set_column  ;goes to set_column
    CALL set_diagonal  ;goes to set_diagonal 
                       
                 
    CMP winner, 1 ; if the winner flag is 1, one of the player has passed all the conditions for win  
    JE game_over  ; goes to game_over condition for the final output 
    
    CALL swap_player  ; for handling player number 
                
    JMP controlGame  ; controlling the game until there is a winner  
    
    
    swap_player:   
        LEA SI,playerNum ;playerNum = 0000 0001 (starting>
        XOR [SI],3 ;0000 0001 XOR 0000 0011 => 0000 0010 <2> - swaps to player 2 
        
        RET ; after completing this condition, returns to the main program 
    
    
          
     
    update_positionArray:
        
        MOV BH,0 
        MOV BL, positionArray[BX]  ;storing turn or '-' stored in positionArray into BL 
    
        LEA SI,playerNum

        
        CMP [SI], "1" ;if player 1
        JE draw_X    
                      
        CMP [SI], "2" ;if player 2 
        JE draw_O  
        
        RET             
                      
    draw_X:
        
        MOV CL,"X" ;store X in CL 
        JMP update_grid

    draw_O: 
                 
        MOV CL, "O" ;store O in CL  
        JMP update_grid    
              
    update_grid: 
            
    MOV [BX],CL  ;store the turn in memory at BX location and grid has that turn on screen  
    RET  
    
                                       
           
           
    set_row:
        MOV CX,0
        RET   
        
            
    check_row: 
        
        CMP CX,0
        JE first_row 
        
        CMP CX,1
        JE second_row
        
        CMP CX,2
        JE third_row 
        
    
    
    
        
    first_row:    
       MOV SI,0   ;for 1st row  (grid:1,2,3>
       JMP check_row_win  

    second_row:    
       MOV SI,3  ;for 2nd row <grid: 4,5,6>
       JMP check_row_win 
    
    third_row:    
       MOV SI,6  ;for 3rd row <grid: 7,8,9>
       JMP check_row_win 
       
       
    check_row_win:
    
        INC CX   
        
        MOV BL,positionArray[SI]  ;store the turn or '-' in the positionArray index into BL 
        MOV BH,0 ;make BH empty 
        MOV AL,[BX] ; store the data stored in BX address from memory into AL (turn or '-'>
        CMP AL,"_"  ; if compare is correct, then the 1st position of the current row is not enough for row win 
        JE check_row ;goes back to check_row  
        
        INC SI  ;if correct is incorrect, moves to the 2nd position of the current row 
        
        MOV BL,positionArray[SI] 
        CMP AL,[BX] ;if compare is correct, then the 2nd position of the current row may lead to a row win 
        JNE check_row ;otherwise, goes back to check_row to go to the next row 
        
        INC SI
        
        MOV BL,positionArray[SI]
        CMP AL,[BX] ;if compare is correct, then the 3rd position of the current row leads to a row win 
        JNE check_row ;otherwise, goes back to check_row to go the last row 
                     
                             
        MOV winner,1 ;winner flag is updated to 1 when all three positions of the current row leads to a win 
        RET
           
    set_column:
        MOV CX,0
        
    check_column:  
        
        CMP CX,0
        JE first_column
        
        CMP CX,1
        JE second_column
        
        CMP CX,2
        JE third_column 
          
     
    RET    
        
    first_column:    
    MOV SI,0    ;for 1st column 
    JMP check_column_win   

    second_column:    
    MOV SI,1   ;for 2nd column 
    JMP check_column_win  
    
    third_column:    
    MOV SI,2  ;for 3rd column 
    JMP check_column_win         

    check_column_win:
    
        INC CX   
        
        MOV BL,positionArray[SI]
        MOV AL,[BX]
        CMP AL,"_"  ; if compare is correct, then there is not enough turn for column win
        JE check_column ;goes back to move to the next column  
        ;if compare is incorrect, the 1st position of the current column may lead to a column win 
        
        ADD SI,3  ;goes to the 2nd position of the current column 
        
        MOV BL,positionArray[SI]
        CMP AL,[BX]  ;if compare is correct, the 2nd position of the current column is closer to column win 
        JNE check_column   ;otherwise goes back to move to the next column 
        
        ADD SI,3  ;goes to the 3rd position of the current column 
        
        MOV BL,positionArray[SI]
        CMP AL,[BX]  ;if compare is correct, the 3rd position of the current column leads to a column win 
        JNE check_column ;otherwise goes back to move to the next column 
                     
                             
        MOV winner,1  ;if all three positions of the current column has a turn, so winner flag is 1 for that player 
        RET     

    
    set_diagonal:
        MOV CX,0
        
    check_diagonal:     
        CMP CX,0
        JE first_diagonal
        
        CMP CX,1
        JE second_diagonal                         
        
        RET    
        
    first_diagonal: ; moving from 1st diagonal point to the second one 
        MOV SI,0  ;starts from grid 1 or 3  
        MOV DX,4  ; for moving to the next diagonal position , i.e to grid 5 
        JMP check_diagonal_win     

    second_diagonal:  ; moving from 2nd diagonal point to the third one    
        MOV SI,2  ;starts from  grid 5  
        MOV DX,2  ; moving to grid 7 or 9 
        JMP check_diagonal_win     
     

    check_diagonal_win:
    
        INC CX   
        
        MOV BL,positionArray[SI]   ;store the turn or '-' in the positionArray index into BL 
        MOV BH,0 ; make BH empty 
        MOV AL,[BX]      ; store the data stored in BX address from memory into AL (turn or '-'>
        CMP AL,"_"   ; check for '-'
        ; if compare is correct, player's 1st turn is not enough for diagonal win
        JE check_diagonal  ;goes back to diagonal_check  
        
        ;if compare is not correct, then checking continues for the next diagonal position 
        
        ADD SI,DX ;for moving in the next diagonal position 
        
        MOV BL,positionArray[SI]  
        MOV BH,0 
        CMP AL,[BX] 
        ; if compare is correct,then checking continues for the last diagonal position  
        JNE check_diagonal   ;if compare is incorrect, then the last diagonal position is not present for win, and goes back to check_diagonal 
        
        ADD SI,DX
        
        MOV BL,positionArray[SI]
        MOV BH,0
        CMP AL,[BX]
        JNE check_diagonal
                     
                             
        MOV winner,1 ;all three positions for diagonal win is present, winner flag is turned 1 for that player 
        RET     

               
    
    game_over:        
        
        CALL set_screen  ;for clearing all the previous game outputs and keeping just the final winning output  
        
        ; for the winning output   
        MOV AH,9
        LEA DX,endingText
        INT 21H  
        
        LEA DX,nextLine 
        INT 21H                      
        
        LEA DX, generateGrid 
        INT 21H
           
        
        LEA DX,nextLine
        INT 21H
        
    
        LEA DX, gameOverText
        INT 21H
          
        
        LEA DX, playerText 
        INT 21H 
        
        
        LEA DX, playerNum
        INT 21H
        
        
        LEA DX,declareWinner 
        INT 21H  
        
        JMP EXIT
         
      
         
    set_positionArray_grid:
        
        MOV AH,9
        LEA SI, generateGrid
        LEA BX, positionArray         
                  
        MOV CX,9 ; to make sure the loop runs 9 times  
        
        RUN_LOOP:
        
        CMP CX,3 ; go to 2nd row 
        JE inc_SI
        
        CMP CX,6 ; go to 3rd row
        JE inc_SI 
        
        
        JMP set_BX
        
        inc_SI:
        INC SI ; go to the next row  
        JMP set_BX
        
        set_BX:                                 
        MOV [BX],SI ; store updated SI in memory 
        ADD SI,2  ; make sure the turn overlaps the '-'
                            
        INC BX                
        LOOP RUN_LOOP
        
        RET
             
           
     
    
    set_screen: 
          
        MOV AH, 15 ;show existing screen only 
        INT 10h   
        
        MOV AH, 0   ;remove previous screen 
        INT 10h
        
        RET
    
    EXIT:
        ENDS 
                   
          
         
          
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
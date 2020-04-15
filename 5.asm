.model small
.stack 100h
.data   

file db 200 dup (?)
file2 db 200 dup (?)
file1 db 200 dup (?)  
pos dw 0 
fileName1 db "file1.txt"
fileName2 db "file2.txt"
size db    ?  
buf db 50 dup (?)
handler1 dw 0
handler2 dw 0
wordForFind 50,?,50 dup (?)
errorMessage db "error$",0Dh,0Ah

.code
start:

    mov ax, @data         
	mov es, ax 		     
	
    xor ch, ch            
	mov cl, ds:[80h] 
	mov si, 81h 
	lea di,file 
	rep movsb      
	
    mov ds,ax        
    lea si,file  
  
checkSpace1:    
  
    cmp [si],' ' 
    jne readFile1
    inc si
    jmp checkSpace1
                     
readFile1:
         
    lea di,file1
    lea bx,fileName1
    mov cl,5	        
    
cycleReadNameFile1: 
         
    mov al,[si]           
    cmp al,[bx]
    jne errorCommandLine      
    mov [di],al                   
    inc di
    inc bx
    inc si 	
    loop cycleReadNameFile1
 	  
	mov al,[bx]
	cmp [si],al
	je readTXT
	
setTXT: 
    cmp [si], ' '
    jne errorCommandLine
    mov [di],'.'
    inc di 
    mov [di],'t'
    inc di   
    mov [di],'x'
    inc di
    mov [di],'t'
    inc di    
   jmp endReadNameFile1
  
readTXT:     

   cmp [si],'.'
   jne errorCommandLine 
   mov [di],'.'
   inc di
   inc si    
   cmp [si],'t'
   jne errorCommandLine 
      
   mov [di],'t'
   inc di
   inc si  
   cmp [si],'x'
   jne errorCommandLine 
     
   mov [di],'x'
   inc di
   inc si 
   cmp [si],'t'
   jne errorCommandLine 
   
   mov [di],'t'
   inc di
   inc si   

endReadNameFile1: 

   mov  byte ptr [di],0
     
checkSpace2:        
	       
    cmp [si],' ' 
    jne readNameFile2
    inc si
    jmp checkSpace2    
                                  
readNameFile2:   

	lea bx,fileName2	
    lea di,file2
    mov cl,5     
    
cycleReadNameFile2: 

    mov al,[si]  
    cmp al,[bx]
    jne errorCommandLine 
    
    mov [di],al
       
    inc di
    inc bx
    inc si 
loop cycleReadNameFile2  
                    	
	mov al,[bx]
	cmp [si],al
	je readTXT2
                    	 
setTXT2:  
    
   cmp [si], ' '
   jne errorCommandLine
   mov [di],'.'
   inc di 
   mov [di],'t'
   inc di   
   mov [di],'x'
   inc di
   mov [di],'t'
   inc di    
   jmp endReadNameFile2
                   
readTXT2:
   cmp [si],'.'
   jne errorCommandLine  
   
   mov [di],'.'
   inc di
   inc si    
   dec size       
   
   cmp [si],'t'
   jne errorCommandLine   
    
   mov [di],'t'
   inc di
   inc si  
   dec size       
   
   cmp [si],'x'
   jne errorCommandLine    
   
   mov [di],'x'
   inc di
   inc si 
   dec size        
   
   cmp [si],'t'
   jne errorCommandLine   
   
   mov [di],'t'
   inc di
   inc si 
                            
endReadNameFile2:  

	mov  byte ptr [di],0 

checkSpace3:  
 
    cmp [si],0
    je errorCommandLine   
    
    cmp [si],' ' 
    jne readWord
    inc si
    jmp checkSpace3  
        
readWord:

    lea di,wordForFind
    add di,2
    mov al,[si]
    mov [di],al  
    inc si
    inc di
    add wordForFind[1],1  
    
cycleReadWord:  

    mov al,[si]
    cmp [si],' '
    je nextCheckCommandLine
    
    cmp [si],0
    je nextCheckCommandLine 
    
    mov al,[si]
    mov [di],al  
    add wordForFind[1],1 
    
    inc si
    inc di
    jmp cycleReadWord 
    
    
nextCheckCommandLine:
    
    cmp [si],' '
    je nextSymbolCheckCommandLine  
    
    cmp [si],0
    je openFiles
    jmp errorCommandLine  
    
    nextSymbolCheckCommandLine:
    inc si   
    jmp nextCheckCommandLine
                     
errorCommandLine: 
  
  lea dx,errorMessage
  mov ah,9
  int 21h
  jmp exitFromProgramm  
 
openFiles:    

  	mov ah, 3Dh			      
	mov al, 00		
	mov cl,01h	        
	mov dx, offset file1        	  
	int 21h  
	jc errorCommandLine     
	mov handler1,ax
	
    mov ah, 3Dh			        
	mov al, 02h	
	mov cl,0h			       
	mov dx, offset file2         	      
	int 21h  
	jc errorCommandLine
	mov handler2,ax     
	
	call clearFile       
	xor cx,cx
	mov ah,42h
    mov bx,handler2
    mov al,0
    mov dx,0
    int 21h      

    xor di,di  
                                      
find:      
   
    lea dx,buf
    lea si,wordForFind 
    add si,2  
    
    mov ah,3Fh  
    mov bx,handler1
    mov cx,1
    int 21h       
    
    cmp al,0  
    je exit 

    mov al,buf[di]        
    cmp al,0Ah
    je find  
     
    cmp al,0Dh  
    je output 
 
    cmp al,' '
    je find   
    
    cmp al,[si] 
    jne  missWord
    je findWord  
    
    jmp find   

findWord:  

    inc si 
    mov cl,wordForFind[1]   
    dec cl    
    
cycleFindWord: 
    push cx
    lea dx,buf
    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h    
    pop cx     
    
    cmp cl,0  
    jg ifSizeNo0
    
    cmp al,0
    je exit

    cmp buf[di],' '
    je moveNewLine 
    
    cmp buf[di],0Dh
    je saveNewLine
    
    jmp missWord
ifSizeNo0:      
     
    cmp al,0
    je output
    
    mov al,buf[di]  
      
    cmp al,0Dh
    je output
      
    cmp al,[si]
    jne missWord
          
    inc si

loop cycleFindWord

    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h      
    
    cmp al,0
    je exit     
    
    mov al,buf[di]
    
    cmp al,0Dh
    je saveNewLine 
    
    cmp al,' '
    jne find
    je moveNewLine 

saveNewLine:       

    xor cx,cx  
    mov ah,42h
    mov bx,handler1
    mov al,1
    mov dx,0
    int 21h  
    
    mov pos,ax 
   jmp find  
   
missWord: 

    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h 

    cmp buf[di],' '
    je find 
    
    cmp buf[di],0Dh
    je output 
    
    cmp al,0
    je output
    
jmp missWord

moveNewLine: 
 
    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h   
    
    cmp al,0
    je exit    
    
    cmp buf[di],0Dh
    jne moveNewLine 
     
     xor cx,cx  
     mov ah,42h
     mov bx,handler1
     mov al,1
     mov dx,0
     int 21h  
    
    mov pos,ax     
   
   jmp find 
    
output:    
 
    xor cx,cx
    mov ah,42h
    mov al,0
    mov bx,handler1     
    mov dx,pos
    int 21h   
  
    lea dx,buf  
    xor al,al 
    
outInFile2:          

    mov ah,3Fh 
    mov cx,1 
    mov bx,handler1
    int 21h   
    
    cmp buf[di],0Dh
    je exitFromOutputInFile2  
    
    cmp al,0
    je exit

    lea dx,buf
    xor al,al	
    
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h      
         
 jmp outInFile2
 
exitFromOutputInFile2:

    mov buf[di],0Dh
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h   
       
    mov buf[di],0Ah
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h   
    
    xor cx,cx  
    mov ah,42h
    mov bx,handler1
    mov al,1
    mov dx,0
    int 21h  
    
    mov pos,ax 
    lea dx,buf
    
    jmp find 
     
exit:     
    cmp handler1,0
    je closeFile2  
    
    mov ah,3Eh
    mov bx,handler1
    int 21h   
    
closeFile2:  
    cmp handler2,0
    je exitFromProgramm     
    
    mov ah,3Eh
    mov bx,handler2
    int 21h    
exitFromProgramm:   
 
    mov ax,4C00h
    int 21h   
    
clearFile proc
    pusha 
     
    mov ah,42h   
    mov al,00h
    mov cx,0 
    mov dx,0
    mov bx,handler2
    int 21h     
clear:           
    mov ah,3Fh 
    mov cx,1 
    mov bx,handler2 
    lea dx,buf
    int 21h    
  
    cmp al,0
    je exitFromClear
    
    mov ah,42h   
    mov al,01h
    mov cx,-1 
    mov dx,-1
    mov bx,handler2
    int 21h    
     
    mov buf[0],' '
    mov ah,40h
    mov cx,1
    mov bx,handler2
    lea dx,buf
    int 21h  

    jmp clear
exitFromClear:    
    popa 
    ret
clearFile endp

end start
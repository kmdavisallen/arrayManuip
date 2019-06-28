TITLE Sorting Random Integers   

; Author: Kevin Allen
; Program 5
; Due 03/04/2018
; Description: Displays authors name, gets a user defined number of random integers stored in an array, then sorts the array,
;				and calculates median

INCLUDE Irvine32.inc

MAX = 200
MIN = 10
HI = 999
LO = 100

.data
p_intro		BYTE	"--Program Introduction--", 0
extraC		BYTE	"**EC:Description, this program uses the quick sort algorithm", 0
intro_1		BYTE	"Welcome to Random Integers by Kevin Allen",0
intro_2		BYTE	"You may choose between 10 and 200 numbers for the array. ",0
prompt_1	BYTE	"Please enter the amount of random numbers to be generated",0 
prompt_Min	BYTE	"The number you entered is too low, please try again", 0
prompt_Max	BYTE	"The number you entered is too high, please try again", 0
space		BYTE	"  ",0
title_1		BYTE	"This is the unsorted array", 0
title_2		BYTE	"This is the sorted array",0
median		BYTE	"The median is: ",0


request		DWORD	?
bottom		DWORD	0
array		DWORD	MAX Dup(?)

.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Displays introduction
;Recieves: none
;Returns: none
;Preconditions: none
; Registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
introduction PROC
	push	ebp
	mov		ebp, esp
	mov		edx, OFFSET p_intro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraC
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLf
	pop		ebp
	ret
introduction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description : Gets data from user and calls validation
;Recieves : none
;Returns : validated integer in request
;Preconditions:  none
;Registers Changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getUserData PROC
	push	ebp
	mov		ebp, esp
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	CrLf
	push	OFFSET request
	call	validate
	pop ebp
	ret
getUserData ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Recieves a user entered integer and makes sure its in range
;Recieves: Address of request
;Returns: Validated integer in request
;Preconditions: User enters a integer, not character or string
;Registers changed: eax, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validate PROC
	push	ebp
	mov		ebp, esp
L_input:
	call	ReadInt
	cmp		eax, MIN
	jl		L_tooLow	 ;compare user value to min/max values and loop untill valid entry
	cmp		eax, MAX
	jg		L_tooHigh
	jmp		L_valid
L_tooLow:				; displays message to user that the entered an invalid number
	mov		edx, OFFSET prompt_Min
	call	WriteString
	call	CrLf
	jmp		L_input
L_tooHigh:				; displays message that user entered too large a munber
	mov		edx, OFFSET prompt_Max
	call	WriteString
	call	CrLf
	jmp		L_input
L_valid:				; valid number has been determined
	mov		ebx, [ebp + 8]
	mov		[ebx], eax	;move the integer into the address at ebp + 8
	pop		ebp
	ret	4
validate ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Fills an array with a user specified number of elements
;Recieves: Address of array and numbers of elements
;Returns: Array is populated with random integers
;Preconditions: User number has been validated to be within range
;Registers changed:eax, ecx, edi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 8]
	mov		ecx, [ebp + 12]
L_fill:					; adapted from lecture slides
	mov		eax, HI
	sub		eax, LO
	inc		eax
	call	RandomRange
	add		eax, LO
	mov		[edi], eax
	add		edi, 4
	loop	L_fill
	pop	ebp
	ret 8
fillArray ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Displays the contents of an array
;Recieves: Address of array, numbers of elements in array, address 
;			of array title
;Returns: none
;Preconditions: none
;Registers changed:eax, ebx, ecx, esi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayList PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 16]
	call	WriteString
	call	CrLf
	mov		ebx, 0		;counter for number of ints displayed
	mov		esi, [ebp + 8]
	mov		ecx, [ebp + 12]
L_show:					;display the number
	mov		eax, [esi]
	call	WriteDec
	add		esi, 4
	mov		edx, OFFSET space
	call	WriteString
	inc		ebx
	cmp		ebx, 10
	je		L_newLine
	jne		L_next
L_newLine:				;move to a new line after 10 numbers have been displayed
	call	CrLf
	mov		ebx, 0
L_next:
	loop	L_show
	call	CrLf
	pop		ebp
	ret 12
displayList ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: sorts an array, with quick-sort algorithm
;			adpated from "pushebp" on  stack overflow.com
;Recieves: upper index, lower index, and address of array
;Returns: sorted array
;Preconditions: none
;Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sortList PROC
	pushad		;save registers
	mov		ebp, esp

	mov		esi, [ebp + 36]		; address of array
	mov		ecx, [ebp + 40]		; low index
	mov		eax, [ebp + 44]		; high index
		
	cmp		ecx, eax
	jge		L_done

	; partition the array and get pivot value
	mov		ebx, ecx				;index counter
	mov		edx, [esi + (eax*4)]	;value of last element in array
			
L_for:
	cmp		ebx, eax				;compare current index to high index
	jge		L_finalSwap

	cmp		edx, [esi + (ebx*4)]	;compare last element to "current" element
	jg		L_nextNum				; swap if greater, skip to next if else
	
L_swap:
	push	edi						; save register
	push	edx						; save register
	mov		edi, [esi + (ebx*4)]	; swap values of the two indexes
	mov		edx, [esi + (ecx*4)]	
	mov		[esi + (ecx*4)], edi
	mov		[esi + (ebx*4)], edx
	inc		ecx						;increment index
	pop		edx
	pop		edi
L_nextNum:
	inc		ebx
	jmp		L_for
L_finalSwap:
	mov		edi, [esi + (ecx*4)]	; swap index element with
	mov		edx, [esi + (eax*4)]	; last element i.e. pivot value
	mov		[esi + (eax*4)], edi
	mov		[esi + (ecx * 4)], edx
	
	;recursive call for lower side of pivot
	dec		ecx				;decrement ebx i.e. pivot value
	push	ecx				;high index
	push	[ebp +40]		;low index
	push	[ebp + 36] 		;array address
	call	sortList
	add		esp, 8
	
	;recursive call for the higher side of pivot
	pop		ecx			; restore pivot
	inc		ecx			; increment pivot

	push	[ebp + 44]	;high index 
	push	ecx			;low index/pivot
	push	[ebp + 36]	;array
	call	sortList
	add		esp, 12		;clean up rest of stack
L_done:
	popad
	ret 
sortList ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Calculates and displays the median
;Recieves: Address of array and size of array
;Returns: none
;Preconditions: none
;Registers changed: eax, ebx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayMedian PROC
	pushad
	mov		ebp, esp
	mov		esi, [ebp + 36]	;array
	mov		eax,[ebp + 40]	;number of elements
	mov		ebx, 2
	cdq
	div		ebx
	cmp		edx, 0
	jne		L_median	;odd number of elements, get median value

	;if number of elements divides evenly, average two middle elements
	mov		ebx, eax
	dec		ebx
	mov		edx, [esi + (eax*4)]
	mov		eax, [esi + (ebx*4)]
	add		eax, edx
	mov		ebx, 2
	cdq
	div		ebx
	cmp		edx, 0
	je		L_displayResults
	inc		eax
	jmp		L_displayResults

L_median:
	mov		ebx, [esi + (eax*4)]
	mov		eax, ebx
	
L_displayResults:
	mov		edx, [ebp + 44]
	call	WriteString
	call	WriteDec
	call	CrLf
	popad
	ret 12

displayMedian ENDP


main PROC
	call	Randomize
	call	introduction
	call	getUserData

	push	request
	push	OFFSET array
	call	fillArray

	push	OFFSET title_1
	push	request
	push	OFFSET array
	call	displayList
	
	dec		request			;decrement to get an index value
	push	request
	push	bottom
	push	OFFSET array
	call	sortList

	inc		request			;increment to return to array size
	push	OFFSET title_2
	push	request
	push	OFFSET array
	call	displayList

	push	OFFSET median
	push	request
	push	OFFSET array
	call	displayMedian

	exit
main ENDP
END main
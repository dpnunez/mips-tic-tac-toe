.data
	board: .word line1, line2, line3
	line1: .word 1, 0, 0
	line2: .word 0, 0, 0
	line3: .word 0, 0, 0

	currentMove: .space 3		# xy\n (BUFFER DE STRING)
	player: .asciiz "Jogador "
	doMove: .asciiz ", faça sua jogada: \n"
	newLine: .asciiz "\n"
	invalidMove: .asciiz "Movimento invalido, insira sua jogada novamente\n"
	valorNaposicao: .asciiz "valor aqui: \n"
.text
main:
	addi $t0, $zero, 1		# t0 = jogador atual
	la $t1, board			# t1 = endere�o de board
	addi $t9, $zero, 0		# t9 = numero de jogadas realizadas
gameLoop:
	jal printPlayerMessage
	jal readPlayerMove
	# move's validation
	jal moveValidation
	beq $v1, 1, gameLoop	# caso a flag de erro na validaçao seja 1, ler novamente a jogada
	# print game
	jal printBoard
	# verifyWin
	jal verifyEnd
	jal togglePlayer
		
	j gameLoop

moveValidation:
	move $t4, $zero
	move $t2, $zero
	move $t5, $zero
	move $t6, $zero
								# verificar se o movimento inserido é valido (está nas coordenada valida não ocupada)
	la $t4, currentMove
	lb $t5, ($t4)
	addi $t5, $t5, -48		# converter char para numbero
	addi $t4, $t4, 1
	lb $t6, ($t4)
	addi $t6, $t6, -48		# converter char para numbero
	
	# validar X
	# if(x < 0 || x > 2) retornar flag de erro
	slti $t7, $t5, 0
	beq $t7, 1, moveInvalid
	sle $t7, $t5, 2
	beqz $t7, moveInvalid
	
	# validar y
	# if(y < 0 || y > 2) retornar flag de erro
	slti $t7, $t6, 0
	beq $t7, 1, moveInvalid
	sle $t7, $t6, 2
	beqz $t7, moveInvalid
	
	# validar se a posicao xy já está ocupada
	sll $t6, $t6, 2
	lw $t2, board($t6)		# endereço da linha
	
	
	sll $t5, $t5, 2
	add $t2, $t2, $t5
	lw $t3, ($t2)
	
	
	bne $t3, 0, moveInvalid		# casa ja ocupada
	
	
	addi $v1, $zero, 0		# flag de retorno em caso de sucesso
	
	jr $ra
	moveInvalid:
		li $v0, 4
		la $a0, invalidMove	
		syscall					# imprimir mensagem de movimento invalido
		
		addi $v1, $zero, 1		# flag de retorno em caso de erro
			
		jr $ra
		

printPlayerMessage:			# Responsavel por imprimir "Jogador X, fa�a sua jogada"
	li $v0,4
	la $a0, player
	syscall
	
	li $v0, 1
	beq $t0, 1, print1
	li $a0, 2
	j printCurrentNumber
	print1:
	li $a0, 1
	printCurrentNumber:
	syscall
	
	li $v0,4
	la $a0, doMove
	syscall
	jr $ra
	
readPlayerMove:
	li $v0,8
	la $a0, currentMove
	li $a1,3
	syscall
	
	li $v0,4
	la $a0, newLine
	syscall
	jr $ra

togglePlayer:
	beq $t0, 1, changeTo2
	addi $t0, $zero, 1
	jr $ra
	changeTo2:
	addi $t0, $zero, 2
	
	addi $t9, $t9, 1
	jr $ra

verifyEnd:
	beq $t9, 9, end
	jr $ra

printBoard:
	addi $t4, $zero, 0		# index row
	addi $t5, $zero, 0		# index column
	loopRow:	beq $t4, 3, endLoopRow
			sll $t8, $t4, 2		# multiplicador para acessar posicao na memoria (4 em 4) [linha]
			la $t2, board($t8)	# endere�o da linha atual

	loopColumn: 	beq $t5, 3, endLoopColumn
			# acessar row e coluna no array (pseudo-matriz)
			sll $t8, $t5, 2		# multiplicador para acessar posicao na memoria (4 em 4) [coluna]
			
			lw $t6, 0($t2)
			add $t6, $t6, $t8
			lw $t7, 0($t6)
				
			li $v0, 1
			move $a0, $t7
			syscall
			addi $t5, $t5, 1
			j loopColumn
	endLoopColumn:	
			la $a0, newLine
			li $v0, 4
			syscall
			addi $t5, $zero, 0
			addi $t4, $t4, 1
			j loopRow
	endLoopRow:
		jr $ra
	
end: sll $0, $0, 0
	

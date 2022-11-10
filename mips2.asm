.data
	player: .asciiz "Jogador "
	doMove: .asciiz ", faça sua jogada: "
	newLine: .asciiz "\n"
	currentMove: .space 3		# xy\n (BUFFER DE STRING)
	
	board: .word line1, line2, line3
	line1: .word 0, 1, 2
	line2: .word 3, 4, 5
	line3: .word 6, 7, 8
.text
main:
	addi $t0, $zero, 1		# t0 = jogador atual
	la $t1, board			# t1 = endere�o de board
	addi $t9, $zero, 0		# t9 = numero de jogadas realizadas
gameLoop:
	jal printPlayerMessage
	jal readPlayerMove
	# move's validation
	# print game
	jal printBoard
	# verifyWin
	jal verifyEnd
	jal togglePlayer
	
	j gameLoop
	
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
	addi $t9, $t9, 1	# verificar pq t9 n atualiza em tempo real
	jr $ra

togglePlayer:
	beq $t0, 1, changeTo2
	addi $t0, $zero, 1
	jr $ra
	changeTo2:
	addi $t0, $zero, 2
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
	

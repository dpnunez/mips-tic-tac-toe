.data
	board: .word line1, line2, line3
	line1: .word 0, 0, 0
	line2: .word 0, 0, 0
	line3: .word 0, 0, 0

	currentMove: .space 3		# yx\n (BUFFER DE STRING)
	player: .asciiz "Jogador "
	doMove: .asciiz ", faça sua jogada: \n"
	newLine: .asciiz "\n"
	invalidMove: .asciiz "Movimento invalido, insira sua jogada novamente\n"
	valorNaposicao: .asciiz "valor aqui: \n"
	instrucoes: .asciiz "Bem vindo ao jogo da velha!\nAs regras sao dessa aplicaçao replicam as regras convencionais desse tipo de jogo.\nPara preencher as celulas do jogo, o usuário que estiver na rodada atual deve informar, através de coordenadas qual posicao deseja preencher.\nEx.: para preencher a celula na primeira linha e na coluna central, deve-se informar 01, ja na ultima linha na coluna e na primeira coluna 20\n\n"

.text
main:
	addi $s0, $zero, 1		# s0 = jogador atual
	la $s1, board			# s1 = endereï¿½o de board
	addi $s6, $zero, 0		# s6 = numero de jogadas realizadas
	
	jal printInstrucoes
gameLoop:
	
	jal printPlayerMessage
	jal readPlayerMove
	jal moveValidation
	beq $v1, 1, gameLoop	# caso a flag de erro na validaÃ§ao seja 1, ler novamente a jogada

	jal registrarMovimento
	jal printBoard
	jal verifyEnd 			# ToDo: verificar vitoria
	jal togglePlayer
		
	j gameLoop


printInstrucoes:
	li $v0,4
	la $a0, instrucoes
	syscall
	jr $ra
	
registrarMovimento:
	la $t4, currentMove
	lb $t5, ($t4)
	addi $t5, $t5, -48		# converter char para numbero = Y
	addi $t4, $t4, 1
	lb $t6, ($t4)
	addi $t6, $t6, -48		# converter char para numbero = X
	
	sll $t5, $t5, 2
	lw $t2, board($t5)		# endereÃ§o da linha
	
	
	sll $t6, $t6, 2
	add $t2, $t2, $t6
	sw $s0, ($t2)
	
	
	
	addi $s6, $s6, 1		# incrementar jogadas
	jr $ra
	

moveValidation:
	move $t4, $zero
	move $t2, $zero
	move $t5, $zero
	move $t6, $zero
								# verificar se o movimento inserido Ã© valido (estÃ¡ nas coordenada valida nÃ£o ocupada)
	la $t4, currentMove
	lb $t5, ($t4)
	addi $t5, $t5, -48		# converter char para numbero = Y
	addi $t4, $t4, 1
	lb $t6, ($t4)
	addi $t6, $t6, -48		# converter char para numbero = X
	
	# validar Y
	# if(y < 0 || y > 2) retornar flag de erro
	slti $t7, $t5, 0
	beq $t7, 1, moveInvalid
	sle $t7, $t5, 2
	beqz $t7, moveInvalid
	
	# validar X
	# if(x < 0 || x > 2) retornar flag de erro
	slti $t7, $t6, 0
	beq $t7, 1, moveInvalid
	sle $t7, $t6, 2
	beqz $t7, moveInvalid
	
	# validar se a posicao yx jÃ¡ estÃ¡ ocupada
	sll $t5, $t5, 2
	lw $t2, board($t5)		# endereÃ§o da linha
	
	
	sll $t6, $t6, 2
	add $t2, $t2, $t6
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
		

printPlayerMessage:			# Responsavel por imprimir "Jogador X, faï¿½a sua jogada"
	li $v0,4
	la $a0, player
	syscall
	
	li $v0, 1
	beq $s0, 1, prins1
	li $a0, 2
	j printCurrentNumber
	prins1:
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
	beq $s0, 1, changeTo2
	addi $s0, $zero, 1
	jr $ra
	changeTo2:
	addi $s0, $zero, 2
	
	jr $ra

verifyEnd:
	beq $s6, 9, end

	jr $ra

printBoard:
	addi $t4, $zero, 0		# index row
	addi $t5, $zero, 0		# index column
	loopRow:	beq $t4, 3, endLoopRow
			sll $t8, $t4, 2		# multiplicador para acessar posicao na memoria (4 em 4) [linha]
			la $t2, board($t8)	# endereï¿½o da linha atual

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
	

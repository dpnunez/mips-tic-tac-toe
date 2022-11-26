.data
	board: .word line1, line2, line3
	line1: .word 0, 0, 1
	line2: .word 0, 0, 0
	line3: .word 0, 0, 0

	currentMove: .space 3		# yx\n (BUFFER DE STRING)
	player: .asciiz "Jogador "
	doMove: .asciiz ", faça sua jogada:\n>"
	newLine: .asciiz "\n"
	invalidMove: .asciiz "Movimento invalido, insira sua jogada novamente\n"
	valorNaposicao: .asciiz "valor aqui: \n"
	instrucoes: .asciiz "Bem vindo ao jogo da velha!\nAs regras sao dessa aplicaçao replicam as regras convencionais desse tipo de jogo.\nPara preencher as celulas do jogo, o usuário que estiver na rodada atual deve informar, através de coordenadas qual posicao deseja preencher.\nEx.: para preencher a celula na primeira linha e na coluna central, deve-se informar 01, ja na ultima linha na coluna e na primeira coluna 20\n\n"
	empateMessage: .asciiz "EMPATE!!\n"
	winner: .asciiz " ganhou!!\n\n\n"
	menu: .asciiz "1 - novo jogo\n2 - sair\n>"
	menuInvalid: .asciiz "opcao invalida, digite novamente:\n>"
.text
main:
	jal printInstrucoes
	
menuLoop:
	jal printMenu
	beq $v1, 1, novoJogo
	beq $v1, 2, end
	jal printMenuInvalid
	j menuLoop
	novoJogo:
	jal clearBoard
	addi $s0, $zero, 1		# s0 = jogador atual
	la $s1, board			# s1 = endereï¿½o de board
	addi $s6, $zero, 0		# s6 = numero de jogadas realizadas
	
	
gameLoop:
	jal printPlayerMessage
	jal readPlayerMove
	jal moveValidation
	beq $v1, 1, gameLoop	# caso a flag de erro na validaÃ§ao seja 1, ler novamente a jogada

	jal registrarMovimento
	jal printBoard
	jal verifyEnd 			# ToDo: verificar vitoria
	bnez $v1, fimJogo		# caso tenha retorno, final de jogo
	jal togglePlayer
	
	j gameLoop

fimJogo:
	move $a1, $v1			# a1 = flag de quem ganhou (-1 = empate)
	jal printEndGameMessage
	j menuLoop
end:
	li $v0,10
	syscall


printMenuInvalid: 
	li $v0,4
	la $a0, menuInvalid
	syscall
	
	jr $ra
printMenu:
	li $v0,4
	la $a0, menu
	syscall
	
	li $v0, 5
    syscall
    
    move $v1, $v0
    jr $ra
    

printEndGameMessage:
	beq $a1, -1, printMessageEmpate
	
	li $v0,4
	la $a0, player
	syscall
	
	li $v0, 1
	move $a0, $a1
	syscall
	
	li $v0,4
	la $a0, winner
	syscall
	j fimPrintGameMessage
	
	
	printMessageEmpate:			# mensagem de empate
	li $v0,4
	la $a0, empateMessage
	syscall
		
	fimPrintGameMessage:
	jr $ra

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
	
	
	# registrar todos as celulas no registrador t0, cada celula é representada por 2bits, os 2 bits menos significativos representam a celula 22 (os mais sig. a celula 00)
	# para auxiliar no gerenciamentos das mascaras/selecoes de linhas, colunas e diagonais, desenvolvemos
	# uma aplicaçao em js interativa que, através de uma interface de dnd, fornece todos os valores necessarios
	# a aplicacao está hospedada em: https://codesandbox.io/s/proud-butterfly-qlonj7?file=/src/App.tsx
	
	addi $t4, $zero, 0		# index row
	addi $t5, $zero, 0		# index column
	qloopRow:	beq $t4, 3, qendLoopRow
			sll $t8, $t4, 2		# multiplicador para acessar posicao na memoria (4 em 4) [linha]
			la $t2, board($t8)	# endereï¿½o da linha atual

	qloopColumn: 	beq $t5, 3, qendLoopColumn
			# acessar row e coluna no array (pseudo-matriz)
			sll $t8, $t5, 2		# multiplicador para acessar posicao na memoria (4 em 4) [coluna]
			
			lw $t6, 0($t2)
			add $t6, $t6, $t8
			lw $t7, 0($t6)
			sll $t0, $t0, 2
			or $t0, $t0, $t7
			
			addi $t5, $t5, 1
			j qloopColumn
	qendLoopColumn:	
			addi $t5, $zero, 0
			addi $t4, $t4, 1
			j qloopRow
	qendLoopRow:
	
	# ============ verificacao linha 2 ==============
	addi $t1, $zero, 0x3F 	# mascara para pegar os valores da primeira linha = 00000000000000000000000000111111 = 3f
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 2
	lui $t2, 0xFFFF 	
	ori $t2, $t2, 0xffea	# mascara de revert para verificar vitoria 1 = 11111111111111111111111111101010 = ffffffea
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xffd5	# mascara de revert para verificar vitoria 2 = 11111111111111111111111111010101 = ffffffd5
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	
	
	# ============ verificacao linha 1 ==============
	move $t2, $zero
	addi $t1, $zero, 0xFC0 	# mascara para pegar os valores da primeira linha = 00000000000000000000111111000000 = FC0
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 1
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xFABF	# mascara de revert para verificar vitoria 1 = 11111111111111111111101010111111 = 0xFFFFFABF
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xF57F	# mascara de revert para verificar vitoria 2 = 11111111111111111111010101111111 = FFFFF57F
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao linha 0 ==============
	move $t2, $zero
	lui $t1, 0x3
	ori $t1, $t1, 0xF000 	# mascara para pegar os valores da primeira linha = 00000000000000111111000000000000 = 3F000
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFE
	ori $t2, $t2, 0xAFFF	# mascara de revert para verificar vitoria 1 = 11111111111111101010111111111111 = 0xFFFEAFFF
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFD
	ori $t2, $t2, 0x5FFF	# mascara de revert para verificar vitoria 2 = 11111111111111010101111111111111 = FFFD5FFF
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao coluna 0 ==============
	move $t2, $zero
	lui $t1, 0x3
	ori $t1, $t1, 0x0C30 	# mascara para pegar os valores da primeira linha = 00000000000000111111000000000000 = 30C30
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFE
	ori $t2, $t2, 0xFBEF	# mascara de revert para verificar vitoria 1 = 11111111111111101111101111101111 = 0xFFFEFBEF
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFD
	ori $t2, $t2, 0xF7DF	# mascara de revert para verificar vitoria 2 =  11111111111111011111011111011111 = FFFDF7DF
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao coluna 1 ==============
	move $t2, $zero
	lui $t1, 0x0
	ori $t1, $t1, 0xC30C 	# mascara para pegar os valores da primeira linha = 00000000000000001100001100001100 = C30C
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xBEFB	# mascara de revert para verificar vitoria 1 = 11111111111111111011111011111011 = 0xFFFFBEFB
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFF
	ori $t2, $t2, 0x7DF7	# mascara de revert para verificar vitoria 2 =  11111111111111110111110111110111 = FFFF7DF7
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao coluna 2 ==============
	move $t2, $zero
	lui $t1, 0x0
	ori $t1, $t1, 0x30C3 	# mascara para pegar os valores da primeira linha = 00000000000000000011000011000011 = 30C3
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xEFBE	# mascara de revert para verificar vitoria 1 = 11111111111111111110111110111110 = 0xFFFFEFBE
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xDF7D	# mascara de revert para verificar vitoria 2 =  11111111111111111101111101111101 = FFFFDF7D
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao diagonal 1 ==============
	move $t2, $zero
	lui $t1, 0x3
	ori $t1, $t1, 0x0303 	# mascara para pegar os valores da primeira linha = 00000000000000110000001100000011 = 30303
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFE
	ori $t2, $t2, 0xFEFE	# mascara de revert para verificar vitoria 1 = 11111111111111101111111011111110 = 0xFFFEFEFE
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFD
	ori $t2, $t2, 0xFDFD	# mascara de revert para verificar vitoria 2 =  11111111111111011111110111111101 = FFFDFDFD
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	# ============ verificacao diagonal 2 ==============
	move $t2, $zero
	lui $t1, 0x0
	ori $t1, $t1, 0x3330 	# mascara para pegar os valores da primeira linha = 00000000000000000011001100110000 = 3330
	and $t1, $t1, $t0		# reg. de celulas com somente a linha 0
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xEEEF	# mascara de revert para verificar vitoria 1 = 11111111111111111110111011101111 = 0xFFFFEEEF
	
	nor $t3, $t2, $t1
	
	move $t2, $zero
	lui $t2, 0xFFFF
	ori $t2, $t2, 0xDDDF	# mascara de revert para verificar vitoria 2 =  11111111111111111101110111011111 = FFFFDDDF
	nor $t4, $t2, $t1
	
	beqz $t3, ganhou
	beqz $t4, ganhou
	
	beq $s6, 9, empate
	
	j skipGanhou
	
	empate:
		addi $v1, $zero, -1
		jr $ra
	ganhou:
		move $v1, $s0
		jr $ra
	skipGanhou:
	move $v1, $zero
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
	

clearBoard:
	addi $t4, $zero, 0		# index row
	addi $t5, $zero, 0		# index column
	cloopRow:	beq $t4, 3, cendLoopRow
			sll $t8, $t4, 2		# multiplicador para acessar posicao na memoria (4 em 4) [linha]
			la $t2, board($t8)	# endereï¿½o da linha atual

	cloopColumn: 	beq $t5, 3, cendLoopColumn
			# acessar row e coluna no array (pseudo-matriz)
			sll $t8, $t5, 2		# multiplicador para acessar posicao na memoria (4 em 4) [coluna]
			
			lw $t6, 0($t2)
			add $t6, $t6, $t8
			sw $zero, 0($t6)
			
			addi $t5, $t5, 1
			j cloopColumn
	cendLoopColumn:	
			la $a0, newLine
			li $v0, 4
			syscall
			addi $t5, $zero, 0
			addi $t4, $t4, 1
			j cloopRow
	cendLoopRow:
		jr $ra


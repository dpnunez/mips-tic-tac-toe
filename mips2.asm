.data
	player: .asciiz "Jogador "
	doMove: .asciiz ", faça sua jogada: "
	newLine: .asciiz "\n"
	currentMove: .space 3		# xy\n
.text
main:
	addi $t0, $zero, 1		# t0 = jogador atual
	addi $t9, $zero, 0		# t9 = numero de jogadas realizadas
gameLoop:
	jal printPlayerMessage
	jal readPlayerMove
	# move's validation
	# print game
	# verifyWin
	jal verifyEnd
	jal togglePlayer
	
	j gameLoop
	
printPlayerMessage:			# Responsavel por imprimir "Jogador X, faça sua jogada"
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
	beq $t9, 2, end
	jr $ra
	
end: sll $0, $0, 0
	

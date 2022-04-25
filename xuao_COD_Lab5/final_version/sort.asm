.text
sort:	
	addi t6,x0,16		# n
	addi t4,x0,1		# i
	addi t5,x0,0		# address of the array
	
Loop1:
	beq t6,t4,exit3		# i==n,goto exit1
	addi t3,x0,1		# else j=1
	addi t0,t5,0
	
Loop2:
	beq t3,t6,exit2		# j==n,stop
	lw t1,0(t0)		 
	addi t0,t0,4
	lw t2,0(t0)
	addi t3,t3,1		# j=j+1
	blt t2,t1,swap		
	jal x0,Loop2		
	
swap:
	sw t2,-4(t0)
	sw t1,0(t0)		
	jal x0,Loop2
	
exit2:
	addi t4,t4,1		# i++
	jal Loop1

exit3:
	add x0,x0,x0	
	add x0,x0,x0

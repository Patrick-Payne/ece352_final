	ori		5	; load 10 into k1
	nop
	nop
	add	k3,k1
	sub	k1,k1
	nop
	nop
	ori		1		; load 1 into k1
	nop
	nop
	sub	k3,k1
	shift  k1,3
	nop
	nop
	ori     31
	nop
	nop
	add k0,k1
	nop
	nop
	store	k0,(k1)
	nop
	nop
    load	k2,(k1)
	ori		6
	nop
	nop
	nand k1,k1
	stop
	ori		5	; load 10 into k1
	add	k3,k1
	sub	k1,k1
	ori		1		; load 1 into k1
	sub	k3,k1
	shiftr  k1,1
	ori     31
	store	k1,(k1)
    load	k0,(k1)
	ori		6
	nand k1,k1
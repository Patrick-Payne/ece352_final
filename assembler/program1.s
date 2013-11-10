; this is just a simple loop that counts from 10 to 0

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
loop	sub		k3,k1
	bnz		loop
	nop
	nop
end	shift k1,3
	bz	end
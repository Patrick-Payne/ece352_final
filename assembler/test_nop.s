; this is just a simple loop that counts from 10 to 0

	ori		5	; load 10 into k1
  add	k3,k1
  sub	k1,k1
  nop
	ori		1		; load 1 into k1
loop	sub		k3,k1
	bnz		loop
end	shift k1,3
	nop
	bz	end
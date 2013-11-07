  ori	5	; load 10 into k1
  add	k3,k1
  sub	k1,k1
  nand  k3,k1
  ori	1
  add   k2,k1
  ori   30
  store	k2,(k1)
  load	k0,(k1)
  ori	6
  add	k3,k1
  sub	k1,k1
	ori		1		; load 1 into k1
loop	sub		k3,k1
	bnz		loop
end	shift k1,3
	nop
	bz	end
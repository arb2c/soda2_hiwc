      	function few_wexhy, t
 
;	Saturation vapor pressure over water.  Wexler (1976) formulation.
;       Input is temperature in degrees K.  e_w is in dyne/cm^2 (microbars).

	td=double(t)
 
	c0 = -2.9912729e3    &   c1 = -6.0170128e3   &   c2 = 1.887643854e1
	c3 = -2.8354721e-2   &   c4 = 1.7838301e-5   &   c5 = -8.4150417e-10
	c6 = 4.4412543e-13   &   D = 2.858487

	term = (c0*td^(-2)) + (c1*td^(-1)) + (c2*td^0) + (c3*td^1) + (c4*td^2)+$
	       (c5*td^3) + (c6*td^4)
	few = exp(term + (D*alog(td)))	; Pa
 
        return, few * 10.
        end

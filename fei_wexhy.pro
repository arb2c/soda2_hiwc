      	function fei_wexhy, t
 
;	Saturation vapor pressure over ice. Hyland and Wexler (1983) formulation
;       Input is temperature in degrees K.  e_i is in dyne/cm^2.

	td=double(t)
 
	c0 = -5.6745359e3    &   c1 = 6.3925247   &   c2 = -9.6778430e-3
	c3 = 6.2215701e-7   &   c4 = 2.0747825e-9   &   c5 = -9.4840240e-13
	D = 4.1635019

	term = (c0*td^(-1)) + (c1*td^(0)) + (c2*td^1) + (c3*td^2) + (c4*td^3)+$
	       (c5*td^4)
	fei = exp(term + (D*alog(td)))	; Pa
 
        return, fei * 10.
        end

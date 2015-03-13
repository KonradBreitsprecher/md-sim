set term x11
set key left
set xl "cores"
set yl "steps/hour"
s1= 20
s2 = 20
s3 = 20
s4 = 40
e1 = 0.5
e2 = 0.5
e3 = 0.5
e4 = 0.5
f(x)=s1*x**e1
g(x)=s2*x**e2
h(x)=s3*x**e3
i(x)=s4*x**e4
fit f(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$2) via s1,e1
fit g(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$3) via s2,e2
fit h(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$4) via s3,e3
fit i(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$5) via s4,e4
p \
'scaling_N_afterEqui.dat' u 1:(3600*50/$2) w p ps 4 t '0ACN=10442p=2400EMI+CDC',\
''                        u 1:(3600*50/$3) w p ps 4 t '10ACN=11412p=2404EMI+966ACN+CDC',\
''                        u 1:(3600*50/$4) w p ps 4 t '20ACN=12673p=2432EMI+2199ACN+CDC',\
''                        u 1:(3600*50/$5) w p ps 4 t '40ACN=12490p=1304EMI+3144ACN+CDC',\
f(x) t sprintf("0ACN  fit = %3.4f*x^%3.4f" ,s1,e1) lc 1 lw 2,\
g(x) t sprintf("10ACN fit = %3.4f*x^%3.4f" ,s2,e2) lc 2 lw 2,\
h(x) t sprintf("20ACN fit = %3.4f*x^%3.4f" ,s3,e3) lc 3 lw 2,\
i(x) t sprintf("40ACN fit = %3.4f*x^%3.4f" ,s4,e4) lc 4 lw 2

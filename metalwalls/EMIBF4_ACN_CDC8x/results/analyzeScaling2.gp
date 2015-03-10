set term x11
set key left
set xl "cores"
set yl "steps/hour"
f(x)=o1+s1*x
g(x)=o2+s2*x
h(x)=o3+s3*x
i(x)=o4+s4*x
fit f(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$2) via o1,s1
fit g(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$3) via o2,s2
fit h(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$4) via o3,s3
fit i(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$5) via o4,s4
p \
'scaling_N_afterEqui.dat' u 1:(3600*50/$2) w p ps 4 t '0ACN=10442p=2400EMI+CDC',\
''                        u 1:(3600*50/$3) w p ps 4 t '10ACN=11412p=2404EMI+966ACN+CDC',\
''                        u 1:(3600*50/$4) w p ps 4 t '20ACN=12673p=2432EMI+2199ACN+CDC',\
''                        u 1:(3600*50/$5) w p ps 4 t '40ACN=12490p=1304EMI+3144ACN+CDC',\
f(x) t sprintf("0ACN fit =  %3.4f + %3.4f" ,o1,s1) lc 1 lw 2,\
g(x) t sprintf("10ACN fit =  %3.4f + %3.4f" ,o2,s2) lc 2 lw 2,\
h(x) t sprintf("20ACN fit =  %3.4f + %3.4f" ,o3,s3) lc 3 lw 2,\
i(x) t sprintf("40ACN fit =  %3.4f + %3.4f" ,o4,s4) lc 4 lw 2

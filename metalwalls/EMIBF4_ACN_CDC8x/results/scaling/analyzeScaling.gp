set term x11
set yr[0:100]
f(x)=o1+s1*x
g(x)=o2+s2*x
h(x)=o3+s3*x
i(x)=o4+s4*x
fit f(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$2) via o1,s1
fit g(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$3) via o2,s2
fit h(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$4) via o3,s3
fit i(x) 'scaling_N_afterEqui.dat' u 1:(3600*50/$5) via o4,s4
p \
'scaling_N_afterEqui.dat' u 1:(3600*50/$2) w lp t '0ACN=10442p=2400EMI+CDC',\
''                        u 1:(3600*50/$3) w lp t '10ACN=11412p=2404EMI+966ACN+CDC',\
''                        u 1:(3600*50/$4) w lp t '20ACN=12673p=2432EMI+2199ACN+CDC',\
''                        u 1:(3600*50/$5) w lp t '40ACN=12490p=1304EMI+3144ACN+CDC',\
f(x) t sprintf("0ACN fit =  %3.4f + %3.4f" ,o1,s1),\
g(x) t sprintf("10ACN fit =  %3.4f + %3.4f" ,o2,s2),\
h(x) t sprintf("20ACN fit =  %3.4f + %3.4f" ,o3,s3),\
i(x) t sprintf("40ACN fit =  %3.4f + %3.4f" ,o4,s4),\
x t sprintf("0ACN fit =  %3.4f + %3.4f/N" ,o1,1),\
x*s2/s1*10442/11412 t sprintf("10ACN fit =  %3.4f + %3.4f/N" ,o2,s2/11412*10442/s1),\
x*s3/s1*10442/12673 t sprintf("20ACN fit =  %3.4f + %3.4f/N" ,o3,s3/12673*10442/s1),\
x*s4/s1*10442/12490 t sprintf("40ACN fit =  %3.4f + %3.4f/N" ,o4,s4/12490*10442/s1)

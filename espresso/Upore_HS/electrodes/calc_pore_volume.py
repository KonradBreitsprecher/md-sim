from numpy import *
from matplotlib.pyplot import *
from scipy.optimize import curve_fit

w = 10 #Pore width
d = 48 #Pore depth
e1 = 4 #Edge radius pore exit
e2 = 2 #Edge radius pore floor
b = 40 #Embedded plane edge length/ slit length
rim = 11 #rim till start of circle
gap = 50 #Gap between electrodes
r = w/2;
#			kern			bulk  		   unt.quad.     unt.rad.	 
volume = 2*b*(w*(d-e1-e2)+gap/2*(2*rim+2*e1+w)+e2*(w-2*e2)+(pi*e2**2/2)+2*(e1**2-pi*e1**2/4))
print volume

width = 2*rim+w+2*e1
print width

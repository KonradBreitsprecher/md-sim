import numpy as np

ifile = open("mesh.dat", 'r')
ofile = open("meshmod.dat", 'w')




bx = 7.14
by = 7.14
bz = 22.09

nx=99
ny=1
nz=99

dx=bx/nx
dy=by/ny
dz=bz/nz

pot = []
for l in ifile:
	e=l.split(' ')
	if len(e) == 4:
		pot.append(e[3])


cnt = 0

print dx, dy, dz

for x in np.linspace(0.0,bx,nx,False):
	for y in np.linspace(0.0,by,ny,False):
		for z in np.linspace(0.0,bz,nz,False):
	
			txt = str(x) + " " +  str(y) + " " +  str(z) + " " + pot[cnt]
			ofile.write(txt)
			cnt += 1

#ofile.write(txt)
	
	
ifile.close()
ofile.close()

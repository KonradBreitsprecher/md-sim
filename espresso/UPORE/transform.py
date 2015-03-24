
ifile=open("mesh.dat")
i = 0
for line in ifile.readlines():
  if (i==0):
    dim, bx, by, bz, rx, ry, rz, ox, oy, oz = line.split()
	
  if len(line) < 2:
    print ""
    continue

  x, z, phi = line.split()
  x = float(x)
  z = float(z)
  phi = float(phi)


  if phi==-1 and z > 13:
    phi=0

  if phi==-1 and z<13:
    phi=1

  print x, 0, z, phi
  i+=1


! This programs calculates the mean number of atoms in different layers.
!the results are in natoms.out1,2,3...in the same order as in the runtime. 
!in each natoms.out1,2,3 : firt colum is time, second colum is left electrode, third is bulk, fourth colum is right electrode

program rdfcalc

IMPLICIT NONE 

INTEGER :: nconfigs,i,j,k,l,ilayer,nionstot,ndifftypes,ipoint,nlayers
INTEGER, ALLOCATABLE, DIMENSION(:) :: nions,ntype
INTEGER, ALLOCATABLE, DIMENSION(:,:) :: counttot
INTEGER, ALLOCATABLE, DIMENSION(:,:,:) :: countpart
DOUBLE PRECISION :: pi=3.14159265d0
DOUBLE PRECISION :: Lx,Ly,Lz,dtime
DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:) :: X,Y,Z,zmin,zmax,qtype
DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:,:) :: qtot
CHARACTER*80 :: filein,filename,filename2
CHARACTER(len=9) :: indi
CHARACTER(len=10) :: fileout
LOGICAL :: threeD

! Reading of the input file and allocation of the allocatable files

open(10,file='natoms.inpt')
read(10,'(a)') filein		! name of the file with the positions
open(11,file=filein,status='old',form='formatted')
read(10,*) nconfigs		! number of configurations in the positions file

read(10,*) Lx, Ly, Lz		! lengths of the cell in the 3 directions
read(10,*) nlayers			! number of layers
ALLOCATE(zmin(nlayers))
ALLOCATE(zmax(nlayers))
do i=1,nlayers
   read(10,*) zmin(i),zmax(i)
end do
read(10,*) ndifftypes		! number of different types of ions in the simulation
ALLOCATE(nions(ndifftypes))
ALLOCATE(qtype(ndifftypes))
ALLOCATE(counttot(nlayers,nconfigs))
ALLOCATE(qtot(nlayers,nconfigs))
ALLOCATE(countpart(nlayers,ndifftypes,nconfigs))
counttot(1:nlayers,1:nconfigs)=0
qtot(1:nlayers,1:nconfigs)=0.0d0
countpart(1:nlayers,:,1:nconfigs)=0

nionstot=0
do i=1,ndifftypes
   read(10,*) nions(i),qtype(i)
   nionstot=nionstot+nions(i)
end do

ALLOCATE(X(nionstot))
ALLOCATE(Y(nionstot))
ALLOCATE(Z(nionstot))

ALLOCATE(ntype(nionstot))
k=1
do i=1,ndifftypes
   do j=1,nions(i)
      ntype(k)=i
      k=k+1
   end do
end do

read(10,*) threeD		! periodic boundary conditions in the three dimensions ?
read(10,*) dtime		! time between two configurations in ps
   
write(6,*)'carreful the program do not work if you do not have 3 columns to investigate'
do k=1,nconfigs
   if (mod(k,50).eq.0) write(6,*) k,' configs on ',nconfigs
   !write(6,*) k,' configs on ',nconfigs
	 do i=1,nionstot
      read(11,*) X(i), Y(i), Z(i)
     ! write(6,*) i,' ion on ',nionstot
      call layers(Z(i),zmin,zmax,nlayers,ilayer)
      counttot(ilayer,k)=counttot(ilayer,k)+1
      ipoint=ntype(i)
      qtot(ilayer,k)=qtot(ilayer,k)+qtype(ipoint)
      countpart(ilayer,ipoint,k)=countpart(ilayer,ipoint,k)+1
   end do
end do

fileout='natoms.out'
indi='123456789'

do i=1,ndifftypes
   filename=fileout//indi(i:i)
   open(20,file=filename,status='new')
   do k=1,nconfigs
      write(20,*) k*dtime,countpart(:,i,k)
   enddo
   close(20)
enddo   

filename='natoms_tot.out'
filename2='charge_tot.out'
open(20,file=filename,status='new')
open(30,file=filename2,status='new')
do k=1,nconfigs
   write(20,*) k*dtime,counttot(:,k)
   write(30,*) k*dtime,qtot(:,k)
enddo
close(20)
close(30)

end program

subroutine layers(z1,zmin,zmax,nlayer,layer1)

implicit none

integer, intent(in) :: nlayer
double precision,intent(in) :: z1
double precision, intent(in), dimension(nlayer) :: zmin,zmax
integer, intent(out) :: layer1

integer :: i

layer1=1
do i=1,nlayer
   if((z1.gt.zmin(i)).and.(z1.lt.zmax(i)))then
       layer1=i
   endif
enddo

return

end subroutine

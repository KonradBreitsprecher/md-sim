program pm2xyz

implicit none 

integer :: nspecmax
parameter (nspecmax=10)
integer :: nconfigs,i,j,nspec,nionstot,nions(nspecmax),k
double precision :: x,y,z
character*3 :: spc(nspecmax)
character*80 :: filein, fileout

write(6,*)'Combien de configs?'
read(5,*)nconfigs
write(6,*)'Combien d especes?'
read(5,*)nspec
if(nspec.gt.nspecmax)then
   write(6,*)'Trop d especes --  modifier le programme'
endif

nionstot=0
do i=1,nspec
     write(6,*)'espece',i
     write(6,*)'Element chimique?'
     read(5,*)spc(i)
     write(6,*)'Combien d ions?'
     read(5,*)nions(i)
     nionstot=nionstot+nions(i)
enddo
write(6,*)'fichier input?'
read(5,*)filein
open(10,file=filein)
write(6,*)'fichier output?'
read(5,*)fileout
open(20,file=fileout)

do i=1,nconfigs
   write(20,*)nionstot
   write(20,*)'pas',i
   do k=1,nspec
      do j=1,nions(k)
         read(10,*) x,y,z
         write(20,*)spc(k),x,y,z
      enddo
   enddo
enddo

close(10)
close(20)

end program

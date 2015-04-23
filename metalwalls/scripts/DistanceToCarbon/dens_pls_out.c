/* This program calcultates ionic densities as a function of the distance to a surface
   from the positions' file from Paul Madden's simulation code (cartesian coordinates). */

/*pour avoir deds densites en nm-3, on multiplie y par 6748. Pour avoir des distances à la surface accesbile en nm on multiplie x par 0.052917. Pour avoir des distances au carbone, on decale x de 0.54980763 (+)

/* To execute the program, you just have to launch it with an input file giving
the following information (program < inputfile)
1) number of analyse folders
2) name of the positions's file 
3) number of configurations in the positions' file
2) name of the positions's file 
3) number of configurations in the positions' file
4) time duration on which we want to average the density, in ps
5) number of steps between 2 configurations (timestep=2fs)
6) name of the surface positions' file
7) length of the box in the 3 cartesian directions
8) number of different species and number of species considered in the calculation
9) number of ions for each species 
10) maximum length explored and number of boxes into which this length will be divided 
11) limits in the z direction zmin,zmax. */

/* The code is written without considering the periodic boundary conditions, so be careful or modify the code ! */ 

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#define L 1000
#define pi 3.14159265

char nom2[500];
char nom3[500];
int a,b,c,d,nions,nions_zap,Nanalyses,nbox,*nspecies,diffspecies,diffmove,*count,nbtotconfigs,nmoyconfigs,moyconfig,tempsmoy,nbblocs,frame,ntot;
double Lx,Ly,Lz,**pos,**boxes,maxlength,zmin,zmax;
int nconfigs[100000];

void read(char**, int);
void write(char**, int);
int find(int j);
void normalize();
void test();

double *dvector(int n);
int *ivector(int n);
double **dmatrix(int nl, int nc);
void **calloc2D(int sizex, int sizey, size_t sizedata);

int main ( void ){
	int taillenom=300;
	char** nom;
	scanf("%d",&Nanalyses); /*number of Analyse folders*/
	nom = (char**) calloc2D(Nanalyses,taillenom,sizeof(char));
	printf("Hello\n");
	read(nom,taillenom);
	write(nom,taillenom);
	printf("The output file is surface_density.out.\n Attention avant de relancer le pogramme il faut effacer les anciens surface density sinon ça va ecraser et pas ecrire a la suite\n");
	return 0;
}

/*Reads the input file and allocates the vectors and matrices*/
void read(char** nom, int taillenom){
	int i;
	char name[taillenom];
	printf("je suis rentre dans read\n");
	scanf("%d",&Nanalyses); /*number of Analyse folders*/
	printf("il y a %d dossiers d'analyses differents\n",Nanalyses);
	nbtotconfigs=0;
	for(i=0;i<Nanalyses;i++){
		printf("valeur du compteur est %i\n",i);
		scanf("%s",name);					/* name of the positions' file */
		strcpy( nom[i], name );
		printf("nomfichierposition(%d):%s\n",i,nom[i]); 
		scanf("%d",&nconfigs[i]);/* number of configurations in the positions's file */
		printf("valeur de nconfigs(%d)=%d\n",i,nconfigs[i]); 
		nbtotconfigs=nbtotconfigs+nconfigs[i];
	}
	scanf("%i",&tempsmoy);/*time duration on which we want to average the density, in ps*/
	scanf("%i",&frame);/*number of steps between 2 configurations*/
	nmoyconfigs=tempsmoy*1000/2/frame;
	nbblocs=(int)(nbtotconfigs/nmoyconfigs)+1;
	scanf("%s",nom2);					/* name of the surface positions' file */
	scanf("%lf %lf %lf",&Lx,&Ly,&Lz);	   		/* lengths of the simulation box */
	scanf("%d %d",&diffspecies,&diffmove);  		/* number of different species */	
	nspecies=ivector(diffspecies+1);
	count=ivector(diffspecies+1);
	for(i=1;i<=diffspecies;i++) scanf("%d",&nspecies[i]); 	/* number of ions for each species */
	scanf("%lf %d",&maxlength,&nbox);			/* number of boxes in the chosen direction */
	scanf("%lf %lf",&zmin,&zmax);	
	nions=0; nions_zap=0;
	for(i=1;i<=diffmove;i++) nions+=nspecies[i];			/* Calculation of the total number of ions */
	for(i=diffmove+1;i<=diffspecies;i++) nions_zap+=nspecies[i];	/* Calculation of the number of ions not considered */
	nspecies[0]=nions;
	printf("%d %d\n",nions,nions_zap);
	boxes=dmatrix(diffmove+1,nbox+1);			/* Boxes to fill in with the number of ions in each box */
	pos=dmatrix(4,nions+1);
	printf("Reading : OK !\n");
}

/* Calculates the number densities and output them */
void write(char** nom, int taillenom){
	FILE *in,*in2,*out;
	char ligne[L+1],ligne2[L];
	int i,j,k,l,nsurf,ibox,ipoint_surf;
	double surf_area,dx,dy,dz,*surfposx,*surfposy,*surfposz,posx,posy,posz,dist,mindist;
	double norm_grad,*surfgradx,*surfgrady,*surfgradz,scal;

	/* Positions of the surface points */
	in2=fopen(nom2,"r");
	fgets(ligne2,L,in2);
	sscanf(ligne2,"%d %lf",&nsurf,&surf_area);
	printf("n_surf_points %d  surf_area %f\n",nsurf,surf_area);
	surfposx=dvector(nsurf+1); surfposy=dvector(nsurf+1); surfposz=dvector(nsurf+1);
	surfgradx=dvector(nsurf+1); surfgrady=dvector(nsurf+1); surfgradz=dvector(nsurf+1);
	for(k=1;k<=nsurf;k++){
		fgets(ligne2,L,in2);	 
		sscanf(ligne2,"%lf %lf %lf %lf %lf %lf",&surfposx[k],&surfposy[k],&surfposz[k],&surfgradx[k],&surfgrady[k],&surfgradz[k]);
	}
	fclose(in2);

	/* Filling of boxes */
	l=0;
	for(a=0;a<Nanalyses;a++){
		printf("valeur de a :%d\n",a); 
		in=fopen(nom[a],"r");
		if (in!=NULL)
			printf("j'ai ouvert %s \n",nom[a]); 
		else
			printf("ERROR reading %s\n",nom[a]);

		printf("valeur de nconfigs(%d):%d\n",a,nconfigs[a]); 
		for(i=0;i<nconfigs[a];i++){
			l++;
			if(i%10==0) printf("Config %d over %d\n",i+1,nconfigs[a]);
			for(j=1;j<=nions;j++){
				//printf("Config %d, Ion %d over %d\n",i+1,j+1,nions);
				fgets(ligne,L,in);
				sscanf(ligne,"%lf %lf %lf",&posx,&posy,&posz);
				mindist=maxlength*1.1; 
				ipoint_surf=1;
				if((posz>=zmin)&&(posz<=zmax)){
					for(k=1;k<=nsurf;k++){
						dx=posx-surfposx[k]; dy=posy-surfposy[k]; dz=posz-surfposz[k];
						/* Periodic boundary conditions */
						dx/=Lx; dy/=Ly; dz/=Lz;
						dx-=round(dx); dy-=round(dy); dz-=round(dz);
						dx*=Lx; dy*=Ly; dz*=Lz;
						dist=dx*dx+dy*dy+dz*dz; dist=sqrt(dist);
						if(dist<=mindist) {mindist=dist; ipoint_surf=k;}
					}
					/* Projection of the vector from the surface to the ion on the surface normal */
					dx=posx-surfposx[ipoint_surf]; dy=posy-surfposy[ipoint_surf]; dz=posz-surfposz[ipoint_surf];
					scal=dx*surfgradx[ipoint_surf]+dy*surfgrady[ipoint_surf]+dz*surfgradz[ipoint_surf];
					norm_grad=surfgradx[ipoint_surf]*surfgradx[ipoint_surf]+surfgrady[ipoint_surf]*surfgrady[ipoint_surf]+surfgradz[ipoint_surf]*surfgradz[ipoint_surf];
					norm_grad=sqrt(norm_grad);
					mindist=fabs(scal/norm_grad);
					ibox=0;
					while((mindist>(ibox*maxlength/nbox))&&(ibox<=nbox+1)) ibox++; 
					if((ibox<=nbox)&&(ibox>=1)){
						boxes[0][ibox]++; boxes[find(j)][ibox]++; count[find(j)]++; count[0]++;
					}
				}
			}
			if(l%nmoyconfigs==0){//ecriture
				for(j=0;j<=diffmove;j++){
					sprintf(nom3,"surface_density.out%d",j);
					out=fopen(nom3,"a");   	  
					for(k=1;k<=nbox;k++){
						boxes[j][k]/=(surf_area*nmoyconfigs*maxlength/nbox);
						if(j==0) fprintf(out,"%e	%e\n",k*maxlength/nbox,boxes[j][k]);
						if((j!=0)&&(j!=diffmove)) fprintf(out,"%e	%e\n",k*maxlength/nbox,boxes[j][k]);
						if(j==diffmove) fprintf(out,"%e	%e\n",k*maxlength/nbox,boxes[j][k]);
						boxes[j][k]=0;
					}
					fprintf(out,"\n");
					fclose(out);
				}
			}//fin de l'écriture
			for(j=1;j<=nions_zap;j++){
				fgets(ligne,L,in);
			}
		} 
		fclose(in);
	}
	//fclose(out);
}

/* Find the species ion j belongs to */
int find(int j){
	int i,sum;
	i=1; sum=nspecies[i];
	while(j>sum) {i++; sum+=nspecies[i];}
	return i;
	printf("Finding : OK !\n");
}


/********************************************************************************************/
/*Allocation dynamique*/

/*char *nom(int Nanalyses)
  {
  return (char *) malloc(Nanalyses*sizeof(char));
  }*/

double *dvector(int n)
{
	return (double *) malloc(n*sizeof(double));
}

int *ivector(int n)
{
	return (int *) malloc(n*sizeof(int));
}

double **dmatrix(int nl, int nc)
{
	int i;
	double **m;
	m=(double **) malloc(nl*sizeof(double*));
	if (m) { m[0]=(double *) malloc(nl*nc*sizeof(double));
		if (m[0]==NULL) return NULL;
		for (i=1;i<nl;i++) m[i]=m[i-1]+nc;
	}
	return m;
}

void **calloc2D(int sizex, int sizey, size_t sizedata)
{
	void **mem ;
	int i ;


	mem = (void**)calloc(sizex,sizeof(void*)) ;
	mem[0] = (void*)calloc(sizex*sizey,sizedata) ;


	for(i=1; i<sizex; i++)
	{
		mem[i] = mem[i-1] + sizey*sizedata ;
	}
	return mem ;
}


void free2D(double **tab)
{
	if(tab)
	{
		free(tab[0]) ;
		free(tab) ;
	}
}






#include <iostream>
#include <string>
#include <stdlib.h>

#include "capacitor.h"

//using namespace std;

//User Input
char* pathToMeshfile = "C:/Entwicklung/gmsh-2.8.4-Windows/Geometries/pore.msh";



int main()
{
    electrode* electrodes;
    double offset[3] = {0,0,20};
    electrodes = new electrode[2] { electrode("C:/Users/Konrad/Documents/CodeBlocksProjects/meshToLJ/meshToLj/left_electrode.msh", 100.0),
                                    electrode("C:/Users/Konrad/Documents/CodeBlocksProjects/meshToLJ/meshToLj/right_electrode.msh",-100.0)};

    capacitor cap(electrodes,2);

    return 0;
}

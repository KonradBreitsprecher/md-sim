#ifndef CAPACITOR_H
#define CAPACITOR_H

#include "triangleMesh.hpp"

#include <iostream>
#include <string>
#include <stdlib.h>

#include <fstream>
#include <sstream>

#include <math.h>

class electrode : public triangleMesh
{
    public:
        electrode();
        electrode(std::string pathToMeshfile, double potential) : triangleMesh(pathToMeshfile) { pot = potential;};
        double pot;
    protected:
    private:
};

class capacitor
{
    public:
        capacitor(electrode* electrodes, int num_electrodes);
    protected:
    private:
};

#endif // CAPACITOR_H

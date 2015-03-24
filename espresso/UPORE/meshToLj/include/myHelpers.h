#ifndef MYHELPERS_H_INCLUDED
#define MYHELPERS_H_INCLUDED

#include <math.h>
#include <string>
#include <sstream>
#include <fstream>
#include <iterator>
#include <vector>

double vecAbs(double* v)
{
    return sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
}

double* vecCross(double* a, double* b)
{
    double *res = new double[3];
    res[0] = a[1]*b[2] - a[2]*b[1];
    res[1] = a[2]*b[0] - a[0]*b[2];
    res[2] = a[0]*b[1] - a[1]*b[0];
    return res;
}

double* vecAdd3(double* a,double* b,double* c)
{
    double *res = new double[3];
    res[0] = a[0]+b[0]+c[0];
    res[1] = a[1]+b[1]+c[1];
    res[2] = a[2]+b[2]+c[2];
    return res;
}

inline void vecSub2(double v1[3], double v2[3], double dv[3])
{
    dv[0] = v1[0] - v2[0];
    dv[1] = v1[1] - v2[1];
    dv[2] = v1[2] - v2[2];
}

double vecSqrOfSub(double v1[3], double v2[3])
{
    return pow(v1[0] - v2[0],2) + pow(v1[1] - v2[1],2) + pow(v1[2] - v2[2],2);
}

double stringToDouble(std::string str)
{
    std::stringstream ss;
    ss << str;
    double result;
    ss >> result;
    return result;
}

#endif // MYHELPERS_H_INCLUDED

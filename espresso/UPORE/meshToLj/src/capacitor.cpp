#include "capacitor.h"

//Electrode geometries
electrode* _electrodes;

//System size
double* _box;
double* _boxMin;
double* _boxMax;
double* _offset;
double* _reso;
double* _pref;
int* _bins;

//Flat Potential Field
double *_T, *_Tnew;
bool *_TisBoundary;

//double ***_T, ***_Tnew;
//std::vector< std::vector< std::vector<double> > > _T;
//std::vector< std::vector< std::vector<double> > > _Tnew;

inline void print_dVec(double* v)
{
    std::cout << v[0] << " " << v[1] << " " << v[2] << std::endl;
}
inline void print_iVec(int* v)
{
    std::cout << v[0] << " " << v[1] << " " << v[2] << std::endl;
}

inline double dround(double x) { return floor(x+0.5); }

inline void worldToGrid(double* worldPoint,int* gridPoint)
{
     gridPoint[0] = (int)dround(((worldPoint[0] - _offset[0]) / _box[0]) * _bins[0]);
     gridPoint[1] = (int)dround(((worldPoint[1] - _offset[1]) / _box[1]) * _bins[1]);
     gridPoint[2] = (int)dround(((worldPoint[2] - _offset[2]) / _box[2]) * _bins[2]);
}


inline void gridToWorld(double* worldPoint,int* gridPoint)
{
    worldPoint[0] = gridPoint[0] * _box[0] / _bins[0] + _offset[0];
    worldPoint[1] = gridPoint[1] * _box[1] / _bins[1] + _offset[1];
    worldPoint[2] = gridPoint[2] * _box[2] / _bins[2] + _offset[2];
}

inline int gridToFlatArrayIndex(int* gridPoint)
{
    return gridPoint[2] + gridPoint[1] * _bins[2] + gridPoint[0] * _bins[2] * _bins[1];
}

/*
inline int worldToFlatArrayIndex(double* worldPoint)
{
    return gridToFlatArrayIndex(worldToGrid(worldPoint));
}
*/

inline int translatedGrid(int* G, int dim, int ds)
{
    return (G[dim] + _bins[dim] + ds) % _bins[dim];
}

inline double getNeighbourSum(double* data, int* G)
{
    //std::cout << data[gridToFlatArrayIndex(translateGrid(G,2,-1))] << std::endl;
    int GxP[3] = {translatedGrid(G,0,1),G[1],G[2]};
    int GxN[3] = {translatedGrid(G,0,-1),G[1],G[2]};
    int GyP[3] = {G[0],translatedGrid(G,1,1),G[2]};
    int GyN[3] = {G[0],translatedGrid(G,1,-1),G[2]};
    int GzP[3] = {G[0],G[1],translatedGrid(G,2,1)};
    int GzN[3] = {G[0],G[1],translatedGrid(G,2,-1)};

    return _pref[0] * (data[gridToFlatArrayIndex(GxP)] + data[gridToFlatArrayIndex(GxN)]) +
           _pref[1] * (data[gridToFlatArrayIndex(GyP)] + data[gridToFlatArrayIndex(GyN)]) +
           _pref[2] * (data[gridToFlatArrayIndex(GzP)] + data[gridToFlatArrayIndex(GzN)]);

                    //double* a = new double[3] {1,1,1};
                    //double b[3] = {1,1,1};
}

inline std::string intToString(int i)
{
    std::string s;
    std::stringstream out;
    out << i;
    return out.str();
}

capacitor::capacitor(electrode* electrodes, int num_electrodes)
{
    _electrodes = electrodes;

    _box = new double[3] {10,10,20};
    _offset = new double[3] {-5,-5,0};

    _bins = new int[3] {50,50,100};
    _reso = new double[3] {_box[0] / _bins[0],_box[1] / _bins[1],_box[2] / _bins[2]};

    double _resoSqr[3] = {_reso[0]*_reso[0],
                          _reso[1]*_reso[1],
                          _reso[2]*_reso[2]};

    //double twoResoDiag = 1.5 / (_resoSqr[0]+_resoSqr[1]+_resoSqr[2]);

    //_pref = new double[3] { _resoSqr[1]* _resoSqr[2] * twoResoDiag,
    //                        _resoSqr[0]* _resoSqr[2] * twoResoDiag,
    //                        _resoSqr[0]* _resoSqr[1] * twoResoDiag};
    double twoResoDiag = 1.0 / 6.0;

    _pref = new double[3] { twoResoDiag,
                            twoResoDiag,
                            twoResoDiag};

    print_dVec(_pref);

    _boxMin = _offset;
    _boxMax = new double[3] { _box[0]+_offset[0],
                              _box[1]+_offset[1],
                              _box[2]+_offset[2]};

    //std::cout << _bins[0] << "," << _bins[1] << "," << _bins[2] << std::endl;

    int num_gridpoints = _bins[0]*_bins[1]*_bins[2];

    _T =    new double[num_gridpoints];
    _Tnew = new double[num_gridpoints];
    _TisBoundary = new bool[num_gridpoints];

    std::cout << "Get surface, write distance volume data for each electrode" << std::endl;
    std::ofstream surfaceGridFile;
    std::string fname = "./surfaceGrid.txt";
    surfaceGridFile.open(fname.c_str());
    for (int i = 0; i < num_electrodes; i++)
    {
        std::cout << "Electrode #" << i << std::endl;

        std::ofstream distVolumeGridFile;
        fname = "./distVolumeGrid" + intToString(i) + ".txt";
        distVolumeGridFile.open(fname.c_str());

        electrode e = _electrodes[i];

        int cnt = 0;
        for (int x = 0; x < _bins[0]; x++)
        {
            std::cout << x*100.0/_bins[0] << "%" << std::endl;
            for (int y = 0; y < _bins[1]; y++)
            {
                for (int z = 0; z < _bins[2]; z++)
                {
                    int G[3] = {x,y,z};
                    double P[3];
                    gridToWorld(P, G);

                    double dist = sqrt(e.distToMesh(P));

                    distVolumeGridFile << P[0] << " " << P[1] << " " << P[2] << " " << dist << "\n";

                    if (dist <= 0.5)
                    {
                        _T[cnt] = e.pot;
                        _Tnew[cnt] = e.pot;
                        _TisBoundary[cnt] = true;
                        surfaceGridFile << P[0] << " " << P[1] << " " << P[2] << "\n";
                    }
                    cnt++;
                }
            }
        }
        distVolumeGridFile.close();
    }
    surfaceGridFile.close();

    std::cout << std::endl << "7-Point Stencil Relaxation with boundary values" << std::endl;
    int num_iterations = 2000;
    for (int i = 0; i < num_iterations; i++)
    {
        double dMax = 0;
        //std::cout << _T[worldToFlatArrayIndex(new double[3] { 2,2,10})] << std::endl;
        int cnt = 0;
        for (int x = 0; x < _bins[0]; x++)
        {
            for (int y = 0; y < _bins[1]; y++)
            {
                for (int z = 0; z < _bins[2]; z++)
                {
                    int G[3] = {x,y,z};
                    //double* P = gridToWorld(G);
                    //int j = gridToFlatArrayIndex(G);

                    if (!_TisBoundary[cnt])
                    {
                        _Tnew[cnt] = getNeighbourSum(_T, G);
                    }

                    cnt++;
                }
            }
        }
        cnt = 0;
        for (int x = 0; x < _bins[0]; x++)
        {
            for (int y = 0; y < _bins[1]; y++)
            {
                for (int z = 0; z < _bins[2]; z++)
                {
                    int G[3] =  {x,y,z};
                    //double* P = gridToWorld(G);
                    //int j = gridToFlatArrayIndex(G);

                    if (!_TisBoundary[cnt])
                    {

                        double d =fabs(_T[cnt]-_Tnew[cnt]);
                        if (dMax < d)
                            dMax = d;

                        _T[cnt] = getNeighbourSum(_Tnew, G);
                    }
                    cnt++;
                }
            }
        }
        if (i % 100 == 0)
        {
            std::cout << dMax << std::endl;
            std::cout << "Iteration " << i << std::endl;
        }


        if (dMax < 1e-10)
        {
            std::cout << "Convergence after " << i << " Iterations" << std::endl;
            break;
        }

    }

    std::cout << std::endl << "Save potential mesh to file" << std::endl;
    std::ofstream potVolumeGridFile;
    potVolumeGridFile.open ("./potVolumeGrid.txt");
    int cnt = 0;
    for (int x = 0; x < _bins[0]; x++)
    {
        for (int y = 0; y < _bins[1]; y++)
        {
            for (int z = 0; z < _bins[2]; z++)
            {
                int G[3] =  {x,y,z};
                double P[3];
                gridToWorld(P, G);

                potVolumeGridFile << P[0] << " " << P[1] << " " << P[2] << " " << _T[cnt] << "\n";
                cnt++;
            }
        }
    }
    potVolumeGridFile.close();
}

#ifndef TRIANGLEMESH_H
#define TRIANGLEMESH_H

class triangle
{
    public:
        double normal[3] = {0};
        double vertices[3][3] = {{0},{0},{0}};
        double edges[3][3] = {{0},{0},{0}};
        double transformationMatrix[4][4] = {{0},{0},{0},{0}};
        double transformedVertices[3][2] = {{0},{0}};
        double helperEdges[9][2] = {{0},{0},{0},{0},{0},{0},{0},{0},{0}};
        double helperGradients[9][2] = {{0},{0},{0},{0},{0},{0},{0},{0},{0}};
        double area = 0;
};

class triangleMesh
{
    public:
        triangleMesh(char* pathToMeshfile);
        double distToMesh(double P[3]);
    protected:
    private:
        triangle* _triangles;
        long _numFaces = 0;
        long getNumFaces(char* pathToMeshfile);
        void transformPoint(int i, double P[3], double pt[3]);
        void transformPoint2D(int i, double P[3], double pt2D[2]);
        double edgeEquation(int i, int j, double p[2]);
        double distToEdge(double A[3],double a[3], double P[3]);
        double distToTriangle(int i, double P[3], double minDist);

};

#endif // TRIANGLEMESH_H

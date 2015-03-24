#include "triangleMesh.h"
#include "myHelpers.h"

#define COPYARRAY(dest, src) memcpy((dest), (src), sizeof((src)))

//Structs


//Helpers
long triangleMesh::getNumFaces(char* pathToMeshfile)
{
    std::ifstream inFile(pathToMeshfile);
    std::string line;
    long faceCnt = 0;
    while (getline(inFile, line))
        if (line.find("facet normal") == 0)
            faceCnt++;
    return faceCnt;
}

void triangleMesh::transformPoint(int i, double P[3], double pt[3])
{
    pt[0] = _triangles[i].transformationMatrix[0][0] * P[0] +
            _triangles[i].transformationMatrix[0][1] * P[1] +
            _triangles[i].transformationMatrix[0][2] * P[2] +
            _triangles[i].transformationMatrix[0][3] * 1;
    pt[1] = _triangles[i].transformationMatrix[1][0] * P[0] +
            _triangles[i].transformationMatrix[1][1] * P[1] +
            _triangles[i].transformationMatrix[1][2] * P[2] +
            _triangles[i].transformationMatrix[1][3] * 1;
    pt[2] = _triangles[i].transformationMatrix[2][0] * P[0] +
            _triangles[i].transformationMatrix[2][1] * P[1] +
            _triangles[i].transformationMatrix[2][2] * P[2] +
            _triangles[i].transformationMatrix[2][3] * 1;
}

void triangleMesh::transformPoint2D(int i, double P[3], double pt2D[2])
{
    double pt[3];
    transformPoint(i,P,pt);
    pt2D[0] = pt[2];
    pt2D[1] = pt[1];
    //std::cout << pt[0] << std::endl;
}

double triangleMesh::edgeEquation(int i, int j, double p[2])
{
    return (p[0] - _triangles[i].helperEdges[j][0]) * _triangles[i].helperGradients[j][1] - (p[1] - _triangles[i].helperEdges[j][1]) * _triangles[i].helperGradients[j][0];
}

double triangleMesh::distToEdge(double A[3],double a[3], double P[3])
{
    //a = np.array(B)-np.array(A)
    double b[3];
    vecSub2(P, A, b);
    return (pow(a[1]*b[2]-a[2]*b[1],2)+pow(a[2]*b[0]-a[0]*b[2],2)+pow(a[0]*b[1]-a[1]*b[0],2))/(a[0]*a[0]+a[1]*a[1]+a[2]*a[2]);
}

double triangleMesh::distToTriangle(int i, double P[3],double minDist)
{
    double pt[3];
    transformPoint(i,P, pt);
    double px = pt[0];
    double pxs = px*px;

    if (pxs > minDist)
        return 1e300;

    double p[2];
    p[0] = pt[2]; p[1] = pt[1];

    if (edgeEquation(i,0,p) < 0)
        if (edgeEquation(i,1,p) < 0)
            if (edgeEquation(i,2,p) > 0)
                if (edgeEquation(i,7,p) < 0)
                    if (edgeEquation(i,8,p) > 0)
                        //print "E3"
                        return distToEdge(_triangles[i].vertices[2],_triangles[i].edges[2],P);
                    else
                        //print "A"
                        return vecSqrOfSub(P,_triangles[i].vertices[0]);
                else
                    //print "C"
                    return vecSqrOfSub(P,_triangles[i].vertices[2]);
            else
                //print "F"
                return pxs;
        else
            if (edgeEquation(i,5,p) < 0) {
                double e6 = edgeEquation(i,6,p);
                if (e6 < 0)
                    if (edgeEquation(i,7,p) < 0)
                        if (edgeEquation(i,8,p) <= 0)
                            //print "A"
                            return vecSqrOfSub(P,_triangles[i].vertices[0]);
                        else
                            //print "E3"
                            return distToEdge(_triangles[i].vertices[2],_triangles[i].edges[2],P);
                    else
                        //print "C"
                        return vecSqrOfSub(P,_triangles[i].vertices[2]);
                else if (e6 == 0)
                        //print "C"
                        return vecSqrOfSub(P,_triangles[i].vertices[2]);
                else if (e6 > 0)
                        //print "E2"
                        return distToEdge(_triangles[i].vertices[1],_triangles[i].edges[1],P);
            }
            else
                //print "B"
                return vecSqrOfSub(P,_triangles[i].vertices[1]);
    else {
        double e3 = edgeEquation(i,3,p);
        if (e3 < 0) {
            double e4 = edgeEquation(i,4,p);
            if (e4 < 0)
                if (edgeEquation(i,5,p) < 0)
                    if (edgeEquation(i,6,p) <= 0)
                    {
                        //print "C"
                        return vecSqrOfSub(P,_triangles[i].vertices[2]);
                    }
                    else
                        //print "E2"
                        return distToEdge(_triangles[i].vertices[1],_triangles[i].edges[1],P);
                else
                    //print "B"
                    return vecSqrOfSub(P,_triangles[i].vertices[1]);
            else if (e4 == 0)
                //print "B"
                return vecSqrOfSub(P,_triangles[i].vertices[1]);
            else
                //print "E1"
                return distToEdge(_triangles[i].vertices[0],_triangles[i].edges[0],P);
        }
        else if (e3 == 0)
            //print "A"
            return vecSqrOfSub(P,_triangles[i].vertices[0]);
        else if (e3 > 0)
            if (edgeEquation(i,8,p) <= 0)
                //print "A"
                return vecSqrOfSub(P,_triangles[i].vertices[0]);
            else
                if (edgeEquation(i,7,p) < 0)
                    //print "E3"
                    return distToEdge(_triangles[i].vertices[2],_triangles[i].edges[2],P);
                else
                    //print "C"
                    return vecSqrOfSub(P,_triangles[i].vertices[2]);
    }

}

//Constructor
triangleMesh::triangleMesh(char* pathToMeshfile)
{

    _numFaces = getNumFaces(pathToMeshfile);
    _triangles = new triangle[_numFaces];

    std::ifstream inFile(pathToMeshfile);
    std::string line;
    double tmpVertices[3][3] = {{0},{0},{0}};
    int vertexCnt = 0;
    int faceCnt = 0;
    while (std::getline(inFile, line))
    {
        std::istringstream ss(line);
        std::istream_iterator<std::string> begin(ss), end;
        std::vector<std::string> arrayTokens(begin, end);

        if (arrayTokens[0] ==  "facet")
        {
            _triangles[faceCnt].normal[0] = stringToDouble(arrayTokens[2]);
            _triangles[faceCnt].normal[1] = stringToDouble(arrayTokens[3]);
            _triangles[faceCnt].normal[2] = stringToDouble(arrayTokens[4]);
        }
        else if (arrayTokens[0] ==  "vertex")
        {
            tmpVertices[vertexCnt][0] = stringToDouble(arrayTokens[1]);
            tmpVertices[vertexCnt][1] = stringToDouble(arrayTokens[2]);
            tmpVertices[vertexCnt][2] = stringToDouble(arrayTokens[3]);
            vertexCnt++;
            if (vertexCnt == 3)
            {
                //Vertices
                COPYARRAY(_triangles[faceCnt].vertices, tmpVertices);
                //Area
                _triangles[faceCnt].area = 0.5 * vecAbs(vecAdd3(vecCross(tmpVertices[0],tmpVertices[1]),
                                                               vecCross(tmpVertices[1],tmpVertices[2]),
                                                               vecCross(tmpVertices[2],tmpVertices[0])));

                //Edges
                vecSub2(tmpVertices[1],tmpVertices[0], _triangles[faceCnt].edges[0]);
                vecSub2(tmpVertices[2],tmpVertices[1], _triangles[faceCnt].edges[1]);
                vecSub2(tmpVertices[0],tmpVertices[2], _triangles[faceCnt].edges[2]);

                //TransformationMatrix
                double nx = _triangles[faceCnt].normal[0];
                double ny = _triangles[faceCnt].normal[1];
                double nz = _triangles[faceCnt].normal[2];
                double s = sin(acos(-nx));
                double transformationMatrix[4][4] = {{-nx , -ny*s           , -nz*s           ,  -nx * -_triangles[faceCnt].vertices[0][0] + -ny * s *            -_triangles[faceCnt].vertices[0][1] + -nz * s *            -_triangles[faceCnt].vertices[0][2]},
                                                     {ny*s, -nx+nz*nz*(1+nx),    -nz*ny*(1+nx), ny*s * -_triangles[faceCnt].vertices[0][0] + (-nx+nz*nz*(1+nx)) * -_triangles[faceCnt].vertices[0][1] + (-nz*ny*(1+nx)) *    -_triangles[faceCnt].vertices[0][2]},
                                                     {nz*s, -ny*nz*(1+nx)   , -nx+ny*ny*(1+nx), nz*s * -_triangles[faceCnt].vertices[0][0] + (-ny*nz*(1+nx)) *    -_triangles[faceCnt].vertices[0][1] + (-nx+ny*ny*(1+nx)) * -_triangles[faceCnt].vertices[0][2]},
                                                     {0   , 0               , 0               , 1 }};
                COPYARRAY(_triangles[faceCnt].transformationMatrix,transformationMatrix);

                //Transform Vertices to 2D
                transformPoint2D(faceCnt, _triangles[faceCnt].vertices[0], _triangles[faceCnt].transformedVertices[0]);
                transformPoint2D(faceCnt, _triangles[faceCnt].vertices[1], _triangles[faceCnt].transformedVertices[1]);
                transformPoint2D(faceCnt, _triangles[faceCnt].vertices[2], _triangles[faceCnt].transformedVertices[2]);

                //Helper edges
                COPYARRAY(_triangles[faceCnt].helperEdges[0], _triangles[faceCnt].transformedVertices[0]);
                COPYARRAY(_triangles[faceCnt].helperEdges[1], _triangles[faceCnt].transformedVertices[1]);
                COPYARRAY(_triangles[faceCnt].helperEdges[2], _triangles[faceCnt].transformedVertices[2]);
                COPYARRAY(_triangles[faceCnt].helperEdges[3], _triangles[faceCnt].transformedVertices[0]);
                COPYARRAY(_triangles[faceCnt].helperEdges[4], _triangles[faceCnt].transformedVertices[1]);
                COPYARRAY(_triangles[faceCnt].helperEdges[5], _triangles[faceCnt].transformedVertices[1]);
                COPYARRAY(_triangles[faceCnt].helperEdges[6], _triangles[faceCnt].transformedVertices[2]);
                COPYARRAY(_triangles[faceCnt].helperEdges[7], _triangles[faceCnt].transformedVertices[2]);
                COPYARRAY(_triangles[faceCnt].helperEdges[8], _triangles[faceCnt].transformedVertices[0]);

                //Helper gradients
                vecSub2(_triangles[faceCnt].transformedVertices[1], _triangles[faceCnt].transformedVertices[0], _triangles[faceCnt].helperGradients[0]);
                vecSub2(_triangles[faceCnt].transformedVertices[2], _triangles[faceCnt].transformedVertices[1], _triangles[faceCnt].helperGradients[1]);
                vecSub2(_triangles[faceCnt].transformedVertices[0], _triangles[faceCnt].transformedVertices[2], _triangles[faceCnt].helperGradients[2]);
                _triangles[faceCnt].helperGradients[3][0] = _triangles[faceCnt].helperGradients[0][1]; _triangles[faceCnt].helperGradients[3][1] = -_triangles[faceCnt].helperGradients[0][0];
                _triangles[faceCnt].helperGradients[4][0] = _triangles[faceCnt].helperGradients[0][1]; _triangles[faceCnt].helperGradients[4][1] = -_triangles[faceCnt].helperGradients[0][0];
                _triangles[faceCnt].helperGradients[5][0] = _triangles[faceCnt].helperGradients[1][1]; _triangles[faceCnt].helperGradients[5][1] = -_triangles[faceCnt].helperGradients[1][0];
                _triangles[faceCnt].helperGradients[6][0] = _triangles[faceCnt].helperGradients[1][1]; _triangles[faceCnt].helperGradients[6][1] = -_triangles[faceCnt].helperGradients[1][0];
                _triangles[faceCnt].helperGradients[7][0] = _triangles[faceCnt].helperGradients[2][1]; _triangles[faceCnt].helperGradients[7][1] = -_triangles[faceCnt].helperGradients[2][0];
                _triangles[faceCnt].helperGradients[8][0] = _triangles[faceCnt].helperGradients[2][1]; _triangles[faceCnt].helperGradients[8][1] = -_triangles[faceCnt].helperGradients[2][0];

                vertexCnt = 0;
                faceCnt++;
            }
        }
    }
    inFile.close();
}

//Public
double triangleMesh::distToMesh(double P[3])
{
    double minDist = 1e10;
    for (int i = 0; i < _numFaces; i++)
    {
        double dist = distToTriangle(i,P,minDist);
        if (minDist > dist)
            minDist = dist;
    }
    return minDist;
}



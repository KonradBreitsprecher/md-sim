Point(1) = {0, 0, 20, 1.0};
Point(2) = {10, 0, 20, 1.0};
Point(3) = {10, 10, 20, 1.0};
Point(4) = {0, 10, 20, 1.0};
Line(1) = {1, 4};
Line(2) = {4, 3};
Line(3) = {3, 2};
Line(4) = {2, 1};
Line Loop(5) = {1, 2, 3, 4};
Plane Surface(6) = {5};
//Reverse Surface {6};
Mesh.Format = 27;
Mesh 3;
Save 'right_electrode.stl';

//Change mesh refinement with 
//gmsh right_electrode.geo -clscale 0.5 -algo front2d

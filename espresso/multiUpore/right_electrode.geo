//Parameters

r = 4;  //Pore half width
d = 48; //Pore depth
e1 = 2; //Edge radius pore exit
e2 = 2; //Edge radius pore floor
b = 40; //Embedded plane edge length
gap = 30; //Gap between electrodes
sx = b/2; sy = b/2; sz = 0;  //Global shift

//Create line shape
Point(1) = {sx + 0, sy -b/2, sz + 0, 1.0};
Point(2) = {sx + r-e2, sy - b/2, sz + 0, 1.0};
Line(1) = {1, 2};
Point(3) = {sx + r-e2, sy - b/2, sz + e2, 1.0};
Point(4) = {sx + r, sy -b/2, sz + e2, 1.0};
Circle(2) = {2, 3, 4};
Point(5) = {sx + r, sy -b/2, sz + d-e1, 1.0};
Line(3) = {4, 5};
Point(6) = {sx + r+e1, sy -b/2, sz + d-e1, 1.0};
Point(7) = {sx + r+e1, sy -b/2, sz + d, 1.0};
Circle(4) = {5, 6, 7};
Point(8) = {sx + b/2, sy -b/2, sz + d, 1.0};
Line(5) = {7, 8};

//Extrude
Extrude {0, b, 0} {
  Line{1, 2, 3, 4, 5};
}

Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{9, 13, 17, 21, 25}; }
}

//Reverse Surface {26,31,36,41,46};


Symmetry {0, 0, 1,-(d+gap/2)} {
  Surface{46, 41, 31, 13, 26, 9, 21, 25, 36, 17}; 
}

Reverse Surface {9, 21, 25, 13, 17};

Mesh.Format = 27;
Mesh 3;
Save 'right_electrode.stl';

//Change mesh refinement with 'gmsh right_electrode.geo -clscale 2.5 -algo front2d'



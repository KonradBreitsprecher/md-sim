//Parameters

r = 4;  //Pore half width
d = 48; //Pore depth
m = 12; //Distance between multipores
e1 = 2; //Edge radius pore exit
e2 = 2; //Edge radius pore floor
b = 40; //Embedded plane edge length
gap = 30; //Gap between electrodes
sx = b/2; sy = b/2; sz = 0;  //Global shift

//Create line shape
Point(1) = {0,0,d, 1.0};
Point(2) = {m/2-e1,0,d, 1.0};
Line(1) = {1, 2};
Point(3) = {m/2-e1,0,d-e1, 1.0};
Point(4) = {m/2,0,d-e1, 1.0};
Circle(2) = {2, 3, 4};
Point(5) = {m/2,0,e2, 1.0};

//TODO  |
//      V 
Line(3) = {4, 5};
Point(6) = {sx + r+e1, sy -b/2, sz + d-e1, 1.0};
Point(7) = {sx + r+e1, sy -b/2, sz + d, 1.0};
Circle(4) = {5, 6, 7};
Point(8) = {sx + b/2, sy -b/2, sz + d, 1.0};
Line(5) = {7, 8};

Point(9) = {sx + r + b/2, sy -b/2, sz + d-e1, 1.0};
Point(10) = {sx + r+e1, sy -b/2, sz + d-e1, 1.0};
Point(11) = {sx + r+e1, sy -b/2, sz + d, 1.0};
Circle(6) = {9,10,11};
Point(8) = {sx + b/2, sy -b/2, sz + d, 1.0};
Line(5) = {7, 8};

//Extrude
Extrude {0, b, 0} {
  Line{1, 2, 3, 4, 5};
}

Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{9, 13, 17, 21, 25}; }
}

Reverse Surface {26,31,36,41,46};

Mesh.Format = 27;
Mesh 3;
Save 'left_electrode.stl';

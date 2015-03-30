//Parameters
flip = -1;
r = flip*2;  //Pore radius
d = flip*3; //Pore depth
e1 = flip*1; //Edge radius pore exit
e2 = flip*1; //Edge radius pore floor
b = flip*10; //Embedded plane edge length

sx = 0; sy = 0; sz = 20;  //Global shift
//Change mesh refinement with 'gmsh pore.geo -clscale 1'

//Create line shape
Point(1) = {sx + 0, sy + 0, sz + 0, 1.0};
Point(2) = {sx + r-e2, sy + 0, sz + 0, 1.0};
Line(1) = {1, 2};
Point(3) = {sx + r-e2, sy + 0, sz + e2, 1.0};
Point(4) = {sx + r, sy + 0, sz + e2, 1.0};
Circle(2) = {2, 3, 4};
Point(5) = {sx + r, sy + 0, sz + d-e1, 1.0};
Line(3) = {4, 5};
Point(6) = {sx + r+e1, sy + 0, sz + d-e1, 1.0};
Point(7) = {sx + r+e1, sy + 0, sz + d, 1.0};
Circle(4) = {5, 6, 7};

//Extrude 4 times
Extrude {{0, 0, 1}, {sx, sy, sz}, Pi/2} {
  Line{1, 2, 3, 4};
}
Extrude {{0, 0, 1}, {sx, sy, sz}, Pi/2} {
  Line{5, 8, 12, 16};
}
Extrude {{0, 0, 1}, {sx, sy, sz}, Pi/2} {
  Line{20, 23, 27, 31};
}
Extrude {{0, 0, 1}, {sx, sy, sz}, Pi/2} {
  Line{35, 38, 42, 46};
}

//Create embedded plane points
Point(56) = {sx + b/2, sy + b/2, sz + d, 1.0};
Point(57) = {sx + -b/2, sy + b/2, sz + d, 1.0};
Point(58) = {sx + -b/2, sy + -b/2, sz + d, 1.0};
Point(59) = {sx + b/2, sy + -b/2, sz + d, 1.0};

//Create embedded plane Lines
Line(65) = {58, 59};
Line(66) = {59, 56};
Line(67) = {56, 57};
Line(68) = {57, 58};

//Create plane surface with hole
Line Loop(69) = {65, 66, 67, 68};
Line Loop(70) = {48, 63, 18, 33};
Plane Surface(71) = {69, 70};

Mesh 3;
Mesh.Format = 27;
Save 'pore2.msh';

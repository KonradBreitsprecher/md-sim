//Parameters

w = width;  //Pore width
d = depth; //Pore depth
e1 = edge_radius1; //Edge radius pore exit
e2 = edge_radius2; //Edge radius pore floor
b = plane_length; //Embedded plane edge length/ slit length
rim = rim_replace; //rim till start of circle
gap = gap_replace; //Gap between electrodes

r = w/2;
sx = rim+e1+r; sy = 0; sz = 0;  //Global shift

//Create line shape
Point(10) = {sx + 0, sy, sz + 0, 1.0};
Point(11) = {sx + r-e2, sy, sz + 0, 1.0};
Line(7) = {10, 11};
Point(12) = {sx + r-e2, sy, sz + e2, 1.0};
Point(13) = {sx + r, sy, sz + e2, 1.0};
Circle(6) = {11, 12, 13};
Point(14) = {sx + r, sy, sz + d-e1, 1.0};
Line(9) = {13, 14};
Point(15) = {sx + r+e1, sy, sz + d-e1, 1.0};
Point(16) = {sx + r+e1, sy, sz + d, 1.0};
Circle(8) = {14, 15, 16};
Point(17) = {sx + rim + r + e1, sy, sz + d, 1.0};
Line(11) = {16, 17};


//Extrude
Extrude {0, b, 0} {
  Line{7,6,9,8,11};
}

//Mirror
Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{15,19,23,27,31}; }
}

//Reverse Surface {26,31,36,41,46};

Mesh.Format = 27;
Mesh 3;
Save Sprintf('path/l_w_pw_%g.stl',w);


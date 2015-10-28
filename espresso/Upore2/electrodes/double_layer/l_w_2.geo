//Parameters

w = width;  //Pore width
d = depth; //Pore depth
e1 = edge_radius1; //Edge radius pore exit
e2 = edge_radius2; //Edge radius pore floor
b = plane_length; //Embedded plane edge length/ slit length
rim = rim_replace; //rim till start of circle
gap = gap_replace; //Gap between electrodes
l=l_replace; //graphit bond length
offset_x = offset_x_replace;
offset_y = offset_y_replace;

r = w/2;
sx = rim+e1+r; sy = 0; sz = 0;  //Global shift

//Create line shape
//lower layer
Point(1) = {sx, offset_y, sz + 0, 1.0};
Point(2) = {sx + r-e2, offset_y, sz + 0, 1.0};
Line(1) = {1, 2};
Point(3) = {sx + r-e2, offset_y, sz + e2+l, 1.0};
Point(4) = {sx + r + l, offset_y, sz + e2+l, 1.0};
Circle(2) = {2, 3, 4};
Point(5) = {sx + r + l, offset_y, sz + d-e1+l, 1.0};
Line(3) = {4, 5};
Point(6) = {sx + r+e1, offset_y, sz + d-e1+l, 1.0};
Point(7) = {sx + r+e1, offset_y, sz + d, 1.0};
Circle(4) = {5, 6, 7};
Point(8) = {sx + rim + r + e1-offset_x, offset_y, sz + d, 1.0};
Line(5) = {7, 8};


//upper layer
sz = l;
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
Extrude {0, b-2*offset_y, 0} {
  Line{1, 2, 3, 4, 5};
}
Extrude {0, b, 0} {
  Line{7,6,9,8,11};
}

//Mirror
Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{15,19,23,27,31}; }
}
Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{35,39,43,47,51}; }
}

//Reverse Surface {26,31,36,41,46};

Mesh.Format = 27;
Mesh 3;
Save Sprintf('path/l_w_pw_%g.stl',w);


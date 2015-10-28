//Parameters

w = width;  //Pore width
d = depth; //Pore depth
e1 = edge_radius1; //Edge radius pore exit
e2 = edge_radius2; //Edge radius pore floor
b = plane_length; //Embedded plane edge length/ slit length
rim = rim_replace; //rim till start of circle
gap = gap_replace; //Gap between electrodes
l=l_replace; //graphit bond length

r = w/2;
sx = rim+e1+r; sy = 0; 
sz = 3.35;  //Global shift

//Create line shape
Point(1) = {sx + 0, sy, sz + 0, 1.0};
Point(2) = {sx + r-e2, sy, sz + 0, 1.0};
Line(1) = {1, 2};
Point(3) = {sx + r-e2, sy, sz + e2, 1.0};
Point(4) = {sx + r, sy, sz + e2, 1.0};
Circle(2) = {2, 3, 4};
Point(5) = {sx + r, sy, sz + d-e1, 1.0};
Line(3) = {4, 5};
Point(6) = {sx + r+e1, sy, sz + d-e1, 1.0};
Point(7) = {sx + r+e1, sy, sz + d, 1.0};
Circle(4) = {5, 6, 7};
Point(8) = {sx + rim + r + e1, sy, sz + d, 1.0};
Line(5) = {7, 8};

//Extrude
Extrude {0, b, 0} {
  Line{1, 2, 3, 4, 5};
}

Symmetry {1, 0, 0, -sx} {
  Duplicata { Surface{9, 13, 17, 21, 25}; }
}

Symmetry {0, 0, 1,-(d+gap/2)} {
 Surface{46, 41, 31, 13, 26, 9, 21, 25, 36, 17}; 
}

Reverse Surface {9, 21, 25, 13, 17};

Mesh.Format = 27;
Mesh 3;
Save Sprintf('path/r_e_pw_%g.stl',w);




//Parameters

side_len = 28;

//Create line shape
Point(1) = {0, 0, 0};
Point(2) = {side_len,0,0};
Line(1) = {1, 2};

//Extrude
Extrude {0, side_len, 0} {
  Line{1};
}

Mesh.Format = 27;
Mesh 3;
Save Sprintf('flat/l_e_g80.stl');

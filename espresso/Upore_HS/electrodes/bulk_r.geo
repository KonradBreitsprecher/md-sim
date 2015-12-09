//Parameters

side_len = 28;
gap = 80; //Gap between electrodes

//Create line shape
Point(1) = {0, 0, gap};
Point(2) = {side_len,0,gap};
Line(1) = {1, 2};

//Extrude
Extrude {0, side_len, 0} {
  Line{1, 2};
}

Reverse Surface {5};

Mesh.Format = 27;
Mesh 3;
Save Sprintf('flat/r_e_g80.stl');

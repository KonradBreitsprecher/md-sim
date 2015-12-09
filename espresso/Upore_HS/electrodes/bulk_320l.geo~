//Parameters

gap = 120; //Gap between electrodes
width = 31;
b=31;

//Create line shape
Point(1) = {0, 0, 0};
Point(2) = {width,0,0};
Line(1) = {1, 2};

//Extrude
Extrude {0, b, 0} {
  Line{1};
}

Mesh.Format = 27;
Mesh 3;
Save Sprintf('bulk/l_e_g120.stl');

$fn = 96;

axial = [3.4, 1.75, 0.3];

translate([-axial[0]/2, -axial[1]/2, 0])
    cube(axial, center = false);
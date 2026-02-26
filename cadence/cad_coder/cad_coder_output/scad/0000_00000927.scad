EPS = 0.01;

translate([0, 0, 0.375])
rotate([90, 0, 0])
linear_extrude(height=0.75 + EPS)
    polygon(points=[[0.296875, 0.0], [0.296875, 0.296875], [0.0, 0.296875], [0.0, 0.0]]);
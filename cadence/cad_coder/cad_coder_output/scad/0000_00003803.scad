EPS = 0.01;

translate([0, 0, -0.0625/2])
linear_extrude(height=-0.0625)
translate([0, 0, 0])
polygon(points=[[0.75, 0.0], [0.75, 0.49736842105263157], [0.0, 0.49736842105263157], [0.0, 0.0]]);
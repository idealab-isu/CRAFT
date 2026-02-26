EPS = 0.01;

translate([-0.75, 0, 0])
rotate([0, 90, 0])
translate([0, 0, -0.453125/2])
linear_extrude(height=0.453125)
    translate([0.7578947368421053, 0])
    circle(r=0.7578947368421053 + EPS);
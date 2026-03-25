EPS = 0.01;

translate([-0.75, 0, 0])
rotate([0, 90, 0])
difference() {
    linear_extrude(height=0.09375 + EPS)
    translate([0.7578947368421053, 0])
    circle(r=0.7578947368421053 + EPS);

    translate([0.7578947368421053, 0])
    circle(r=0.4736842105263158);
}
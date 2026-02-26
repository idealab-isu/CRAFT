EPS = 0.01;

translate([-0.75, 0, 0])
rotate([0, 90, 0])
difference() {
    cylinder(h=0.375 + EPS, r=0.7578947368421053, center=true);
    translate([0, 0, -EPS])
    cylinder(h=0.375 + 2*EPS, r=0.4578947368421053, center=true);
}
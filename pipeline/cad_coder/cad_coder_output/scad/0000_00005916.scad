EPS = 0.01;

// Solid 0
translate([-0.5, 0, 0])
rotate([0, 90, 0])
translate([0, 0, 0.75/2])
cylinder(h=0.75 + EPS, r=0.5052631578947369, center=true);

// Solid 1 (cut from Solid 0)
translate([0, -0.078125, 0])
rotate([0, 0, 90])
translate([0.1475328947368421/2, 0.359375/2, 0])
difference() {
    cube([0.1475328947368421 + EPS, 0.359375 + EPS, 1.0 + EPS], center=true);
}

// Solid 2 (cut from Solid 0)
translate([-0.140625, 0, 0.1484375])
rotate([0, 90, 0])
translate([0, 0, 0.2734375/2])
difference() {
    cylinder(h=0.2734375 + EPS, r=0.1381578947368421, center=true);
}
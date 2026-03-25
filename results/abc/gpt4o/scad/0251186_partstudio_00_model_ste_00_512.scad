$fn=64;

module elbow_bracket() {
    // Larger rectangular block
    translate([-0.1, -0.05, -0.05])
    cube([0.05, 0.1, 0.1]);

    // Smaller rectangular tongue
    translate([0.05, -0.025, -0.025])
    cube([0.05, 0.05, 0.05]);

    // Curved body
    translate([0, 0, -0.025])
    rotate([0, 90, 0])
    cylinder(r=0.025, h=0.1, center=true);

    // Rounded/obround end-cap feature
    translate([0.075, 0, 0])
    rotate([0, 90, 0])
    cylinder(r=0.0125, h=0.05, center=true);

    // Two small rectangular lugs/steps
    translate([0.075, 0.0125, 0.0125])
    cube([0.01, 0.025, 0.01]);

    translate([0.075, -0.0375, 0.0125])
    cube([0.01, 0.025, 0.01]);
}

elbow_bracket();
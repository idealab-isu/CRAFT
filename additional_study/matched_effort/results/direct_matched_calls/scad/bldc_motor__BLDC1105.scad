$fn = 128;

// Brushless DC motor (simplified) with stator: Ø14.0mm x 11.75mm
// Model includes: stator can, endbells, shaft, mounting base ring, and 3 phase wires.

stator_d = 14.0;
stator_h = 11.75;

// Proportions (typical small BLDC outrunner-ish can)
can_wall = 0.6;
endbell_h = 1.2;
cap_lip = 0.4;

shaft_d = 2.0;
shaft_front_len = 8.0;
shaft_rear_len  = 2.0;

wire_d = 1.0;
wire_len = 18.0;
wire_spacing = 1.6;

module motor_body() {
    // Outer can (stator housing)
    color([0.25,0.25,0.27])
    difference() {
        cylinder(d = stator_d, h = stator_h);
        translate([0,0,can_wall])
            cylinder(d = stator_d - 2*can_wall, h = stator_h - 2*can_wall);
    }

    // Front endbell
    color([0.55,0.55,0.58])
    translate([0,0,stator_h - endbell_h])
    difference() {
        cylinder(d = stator_d - 0.2, h = endbell_h);
        // shaft hole
        translate([0,0,-0.01]) cylinder(d = shaft_d + 0.4, h = endbell_h + 0.02);
    }

    // Rear endbell
    color([0.55,0.55,0.58])
    translate([0,0,0])
    difference() {
        cylinder(d = stator_d - 0.2, h = endbell_h);
        // shaft hole (rear bearing)
        translate([0,0,-0.01]) cylinder(d = shaft_d + 0.4, h = endbell_h + 0.02);
    }

    // Small lip rings (visual detail)
    color([0.35,0.35,0.38])
    translate([0,0,0])
    difference() {
        cylinder(d = stator_d + 0.6, h = cap_lip);
        translate([0,0,-0.01]) cylinder(d = stator_d - 0.4, h = cap_lip + 0.02);
    }

    color([0.35,0.35,0.38])
    translate([0,0,stator_h - cap_lip])
    difference() {
        cylinder(d = stator_d + 0.6, h = cap_lip);
        translate([0,0,-0.01]) cylinder(d = stator_d - 0.4, h = cap_lip + 0.02);
    }

    // Shaft (through)
    color([0.75,0.75,0.78])
    translate([0,0,-shaft_rear_len])
    cylinder(d = shaft_d, h = stator_h + shaft_front_len + shaft_rear_len);

    // Rear wire grommet bump
    color([0.15,0.15,0.16])
    translate([0, -(stator_d/2 + 0.8), endbell_h*0.35])
    rotate([90,0,0])
    cylinder(d = 3.2, h = 2.0);

    // Three phase wires exiting rear
    for (i = [-1,0,1]) {
        wire_col = (i==-1) ? [0.9,0.1,0.1] : (i==0 ? [0.1,0.1,0.1] : [0.95,0.8,0.1]);
        color(wire_col)
        translate([i*wire_spacing, -(stator_d/2 + 1.8), endbell_h*0.6])
        rotate([90,0,0])
        cylinder(d = wire_d, h = wire_len);
    }
}

motor_body();
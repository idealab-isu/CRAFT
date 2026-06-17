$fn=96;

// Brushless DC motor (simplified) with 11.5mm stator diameter and 9.5mm height
// Model includes: stator can, endcaps, shaft, and three mounting wires.

stator_d = 11.5;
motor_h  = 9.5;

// Visual proportions (typical micro BLDC)
can_wall = 0.35;
endcap_h = 1.2;
shaft_d  = 1.0;
shaft_len_front = 6.0;
shaft_len_back  = 1.5;

wire_d = 0.6;
wire_len = 10;

module motor_body() {
    // Outer can
    color([0.65,0.65,0.68])
    difference() {
        cylinder(d=stator_d, h=motor_h);
        translate([0,0,can_wall])
            cylinder(d=stator_d-2*can_wall, h=motor_h-2*can_wall);
    }

    // Front endcap
    color([0.15,0.15,0.16])
    translate([0,0,motor_h-endcap_h])
        cylinder(d=stator_d-0.2, h=endcap_h);

    // Back endcap
    color([0.15,0.15,0.16])
    translate([0,0,0])
        cylinder(d=stator_d-0.2, h=endcap_h);

    // Shaft (front)
    color([0.8,0.8,0.82])
    translate([0,0,motor_h])
        cylinder(d=shaft_d, h=shaft_len_front);

    // Shaft (back stub)
    color([0.8,0.8,0.82])
    translate([0,0,-shaft_len_back])
        cylinder(d=shaft_d, h=shaft_len_back);

    // Small front boss around shaft
    color([0.2,0.2,0.22])
    translate([0,0,motor_h-endcap_h])
        cylinder(d=3.2, h=endcap_h);

    // Wires exiting from back
    for (a = [0, 120, 240]) {
        color([0.85,0.2,0.2])
        rotate([0,0,a])
        translate([stator_d*0.28, 0, 0.6])
            rotate([90,0,0])
                cylinder(d=wire_d, h=wire_len);
    }
}

motor_body();
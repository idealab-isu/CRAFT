$fn=96;

// Brushless DC motor (simplified) with 9.0mm stator diameter and 8.0mm height
// Units: mm

stator_d = 9.0;
stator_h = 8.0;

// Simple proportions for a tiny BLDC motor representation
can_wall = 0.35;
can_d = stator_d + 2*can_wall;          // outer can diameter
can_h = stator_h + 1.2;                 // slightly taller than stator

endcap_h = 0.6;
base_flange_h = 0.8;

shaft_d = 1.5;
shaft_len_top = 6.0;
shaft_len_bottom = 1.5;

bearing_d = 3.0;
bearing_h = 1.2;

wire_d = 0.7;
wire_len = 6.0;

module motor_bldc_9x8() {
    union() {
        // Outer can
        color([0.65,0.65,0.68])
        translate([0,0,base_flange_h])
        cylinder(d=can_d, h=can_h);

        // Top endcap
        color([0.55,0.55,0.58])
        translate([0,0,base_flange_h + can_h])
        cylinder(d=can_d*0.98, h=endcap_h);

        // Bottom base flange
        color([0.45,0.45,0.48])
        cylinder(d=can_d*1.05, h=base_flange_h);

        // Stator core (inside can)
        color([0.25,0.25,0.28])
        translate([0,0,base_flange_h + (can_h - stator_h)/2])
        difference() {
            cylinder(d=stator_d, h=stator_h);
            cylinder(d=stator_d*0.45, h=stator_h + 0.2);
        }

        // Rotor hub (simplified)
        color([0.35,0.35,0.38])
        translate([0,0,base_flange_h + (can_h - stator_h)/2])
        cylinder(d=stator_d*0.55, h=stator_h);

        // Bearings (simplified rings)
        color([0.15,0.15,0.16])
        translate([0,0,base_flange_h + 0.6])
        difference() {
            cylinder(d=bearing_d, h=bearing_h);
            cylinder(d=shaft_d*1.05, h=bearing_h + 0.2);
        }

        color([0.15,0.15,0.16])
        translate([0,0,base_flange_h + can_h + endcap_h - bearing_h - 0.2])
        difference() {
            cylinder(d=bearing_d, h=bearing_h);
            cylinder(d=shaft_d*1.05, h=bearing_h + 0.2);
        }

        // Shaft
        color([0.75,0.75,0.78])
        translate([0,0,base_flange_h + can_h + endcap_h])
        cylinder(d=shaft_d, h=shaft_len_top);

        color([0.75,0.75,0.78])
        translate([0,0,-shaft_len_bottom])
        cylinder(d=shaft_d, h=shaft_len_bottom);

        // Wire leads (two)
        color([0.1,0.1,0.1])
        translate([can_d*0.35, -can_d*0.25, 0.2])
        rotate([0,90,0])
        cylinder(d=wire_d, h=wire_len);

        color([0.1,0.1,0.1])
        translate([can_d*0.35, can_d*0.25, 0.2])
        rotate([0,90,0])
        cylinder(d=wire_d, h=wire_len);
    }
}

motor_bldc_9x8();
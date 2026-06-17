$fn = 128;

// Brushless DC motor (simplified) with stator diameter 14.0mm and height 11.75mm
stator_d = 14.0;
stator_h = 11.75;

// Simple proportions for a small outrunner-style BLDC
can_wall = 0.8;
can_overhang = 0.6;
can_d = stator_d + 2*(can_wall + can_overhang);
can_h = stator_h + 2.0;

base_d = stator_d + 2.0;
base_h = 2.0;

shaft_d = 2.0;
shaft_h = 10.0;

mount_hole_d = 1.6;
mount_hole_r = (base_d/2) - 2.0;

wire_exit_w = 3.0;
wire_exit_h = 2.0;
wire_exit_len = 4.0;

module motor() {
    union() {
        // Base plate
        difference() {
            cylinder(d=base_d, h=base_h);
            // Mount holes (4x)
            for (a = [0:90:270]) {
                rotate([0,0,a])
                    translate([mount_hole_r,0,-0.1])
                        cylinder(d=mount_hole_d, h=base_h+0.2);
            }
            // Wire exit notch
            translate([base_d/2 - 0.5, -wire_exit_w/2, base_h - wire_exit_h])
                cube([wire_exit_len, wire_exit_w, wire_exit_h+0.2], center=false);
        }

        // Stator (reference geometry)
        translate([0,0,base_h])
            color([0.35,0.35,0.35])
                cylinder(d=stator_d, h=stator_h);

        // Rotor can (outer shell)
        translate([0,0,base_h - 0.2])
            color([0.75,0.75,0.78])
            difference() {
                cylinder(d=can_d, h=can_h);
                translate([0,0,0.6])
                    cylinder(d=can_d - 2*can_wall, h=can_h);
                // Bottom opening
                translate([0,0,-0.1])
                    cylinder(d=can_d - 2*can_wall, h=1.0);
            }

        // Top cap lip
        translate([0,0,base_h + can_h - 0.8])
            color([0.7,0.7,0.72])
                cylinder(d=can_d - 0.6, h=0.8);

        // Shaft
        translate([0,0,base_h + can_h])
            color([0.6,0.6,0.6])
                cylinder(d=shaft_d, h=shaft_h);

        // Simple bell vents (slots)
        translate([0,0,base_h + 1.5])
            color([0.65,0.65,0.68])
            difference() {
                // thin decorative ring
                cylinder(d=can_d - 0.4, h=can_h - 3.0);
                cylinder(d=can_d - 1.6, h=can_h - 3.0);
                for (a=[0:30:330]) {
                    rotate([0,0,a])
                        translate([can_d/2 - 1.2, 0, (can_h - 3.0)/2])
                            cube([2.2, 1.2, can_h], center=true);
                }
            }
    }
}

motor();
// Leadscrew nut housing, 8.0mm x 10.2mm x 15.0mm block
// Adds a central leadscrew bore and two mounting through-holes.
// Overall outer size remains exactly 8.0 x 10.2 x 15.0 (X x Y x Z).

$fn = 96;

block_w = 8.0;    // X
block_d = 10.2;   // Y
block_h = 15.0;   // Z

// Features (typical small nut housing details)
lead_bore_d = 4.2;     // leadscrew clearance bore (along Z)
mount_hole_d = 2.2;    // mounting holes (along Z)
mount_spacing_y = 6.0; // center-to-center spacing along Y

eps = 0.02;

module nut_housing() {
    difference() {
        // Outer block
        cube([block_w, block_d, block_h], center=true);

        // Central leadscrew bore (through Z)
        cylinder(d=lead_bore_d, h=block_h + 2*eps, center=true);

        // Two mounting holes (through Z), symmetric about Y
        for (sy = [-1, 1]) {
            translate([0, sy * mount_spacing_y/2, 0])
                cylinder(d=mount_hole_d, h=block_h + 2*eps, center=true);
        }
    }
}

nut_housing();
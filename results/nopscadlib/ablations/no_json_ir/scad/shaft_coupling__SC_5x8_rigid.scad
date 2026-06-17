$fn = 96;

// Rigid shaft coupling: 5.0mm to 8.0mm bore, 12.5mm OD, 25.0mm long
od  = 12.5;
len = 25.0;

bore1_d = 5.0;   // one side
bore2_d = 8.0;   // other side

// Split clamp slit (single slit along full length)
slit_w = 0.8;                 // slit width
slit_depth = od/2 + 0.6;      // ensure it fully opens to outside

// Set-screw / grub screw holes (radial), one per side
screw_d = 2.0;
screw_head_d = 3.6;           // simple counterbore
screw_head_h = 1.6;

eps = 0.02;

module coupling() {
    difference() {
        // Outer body
        cylinder(d=od, h=len, center=true);

        // Stepped bore: split exactly at z=0
        translate([0, 0, -len/4])
            cylinder(d=bore1_d, h=len/2 + 2*eps, center=true);
        translate([0, 0,  len/4])
            cylinder(d=bore2_d, h=len/2 + 2*eps, center=true);

        // Split slit: cut from OD inward, guaranteed to break outer surface
        // Place so the outer face of the cutter extends beyond OD by eps.
        translate([od/2 - slit_depth/2 + eps, 0, 0])
            cube([slit_depth + 2*eps, slit_w, len + 4*eps], center=true);

        // Set-screw holes: one on each half, radial through Y
        for (zpos = [-len/4, len/4]) {
            // Through hole
            translate([0, 0, zpos])
                rotate([90, 0, 0])
                    cylinder(d=screw_d, h=od + 2*eps, center=true);

            // Counterbore on +Y side (opens to outside)
            translate([0, od/2 - screw_head_h/2 + eps, zpos])
                rotate([90, 0, 0])
                    cylinder(d=screw_head_d, h=screw_head_h + 2*eps, center=true);
        }
    }
}

coupling();
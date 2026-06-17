$fn = 128;

// Rigid shaft coupling: 5mm to 8mm stepped bore, 12.5mm OD, 25mm long
// Adds visible rigid-coupling features: center flange, split clamp slots, and set-screw holes.

od = 12.5;
len = 25.0;

bore1_d = 5.0;   // left side bore
bore2_d = 8.0;   // right side bore

// Feature sizes (kept proportional to OD/length)
flange_d = 14.5;          // small center flange to visually read as a coupling
flange_w = 2.0;           // axial width of flange

slot_w = 1.2;             // clamp split slot width
slot_depth = od/2 + 0.6;  // ensure slot cuts through OD
slot_h = len/2 - flange_w/2; // one slot per half, stops at flange

setscrew_d = 2.2;         // through-hole for set screw (visual feature)
setscrew_z_off = len/4;   // centered in each half
setscrew_y = 0;           // radial direction handled by rotation

eps = 0.02;

module coupling() {
    difference() {
        // Outer body with a center flange (single connected solid)
        union() {
            cylinder(d = od, h = len, center = false);

            translate([0, 0, len/2 - flange_w/2])
                cylinder(d = flange_d, h = flange_w, center = false);
        }

        // Stepped bores meeting at mid-plane
        translate([0, 0, -eps])
            cylinder(d = bore1_d, h = len/2 + eps*2, center = false);

        translate([0, 0, len/2])
            cylinder(d = bore2_d, h = len/2 + eps*2, center = false);

        // Split clamp slots (one per half), cut from OD to centerline
        // Left half slot
        translate([0, 0, (len/4) - slot_h/2])
            cube([slot_depth*2, slot_w, slot_h + eps*2], center = true);

        // Right half slot (rotated 90° for visual distinction)
        translate([0, 0, (3*len/4) - slot_h/2])
            rotate([0, 0, 90])
                cube([slot_depth*2, slot_w, slot_h + eps*2], center = true);

        // Set-screw holes (radial through-holes), one per half
        // Left half
        translate([0, 0, setscrew_z_off])
            rotate([90, 0, 0])
                cylinder(d = setscrew_d, h = od + 2, center = true);

        // Right half
        translate([0, 0, len - setscrew_z_off])
            rotate([90, 0, 90])
                cylinder(d = setscrew_d, h = od + 2, center = true);
    }
}

coupling();
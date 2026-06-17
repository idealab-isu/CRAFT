$fn = 96;

// T-slot nut for 3.0mm screws (mm)
screw_d = 3.0;
hole_d  = 3.2;          // clearance for M3
across_flats = 6.0;     // hex across flats
thickness = 2.75;       // total thickness

// Generic T-slot nut proportions (adjust to your extrusion slot if needed)
slot_w = 6.0;           // base width (inside-slot capture)
slot_l = 10.0;          // base length (along slot)
neck_w = 4.0;           // neck width (fits slot opening)
neck_l = slot_l;        // neck length
neck_h = 1.25;          // neck height
base_h = thickness - neck_h;

// Derived
hex_R = across_flats / sqrt(3); // circumradius for hex with given across-flats
eps = 0.05;

module hex_prism(h, r) {
    cylinder(h = h, r = r, $fn = 6, center = true);
}

difference() {
    union() {
        // Base block: centered at Z=0
        translate([0, 0, -thickness/2 + base_h/2])
            cube([slot_l, slot_w, base_h], center = true);

        // Neck block: sits on top of base, overlaps slightly to ensure connectivity
        translate([0, 0, -thickness/2 + base_h + neck_h/2 - eps])
            cube([neck_l, neck_w, neck_h], center = true);

        // Hex boss: same overall thickness, centered at Z=0 (ensures 6.0mm across flats)
        // Slight overlap into neck to guarantee one connected solid
        translate([0, 0, 0])
            hex_prism(thickness + 2*eps, hex_R);
    }

    // Through-hole for 3.0mm screw (clearance)
    cylinder(h = thickness + 2, d = hole_d, center = true, $fn = 64);
}
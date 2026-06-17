$fn = 80;

// Target specs (mm)
screw_d      = 4.0;   // for 4.0mm screw (clearance hole used)
across_flats = 6.0;   // hex across flats (wrench size)
thickness    = 3.25;  // overall thickness (Z)

// Clearances (mm)
hole_clearance = 0.35;
hex_clearance  = 0.10;

// T-slot nut geometry (simple, typical profile)
// Z split: head + neck = thickness
head_h = thickness * 0.62;
neck_h = thickness - head_h;

// Planform sizes (X = slot width direction, Y = along slot)
head_w = across_flats + 2.0;   // wider head to catch slot lips
neck_w = across_flats - 0.6;   // narrower neck to slide in slot
nut_len = max(10.0, across_flats * 1.8);

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

module hex_prism_across_flats(af, h, center=false) {
    // across_flats = sqrt(3) * R  (R = circumradius)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6, center = center);
}

module tslot_nut_body() {
    union() {
        // Neck (bottom)
        translate([0, 0, neck_h/2])
            cube([neck_w, nut_len, neck_h + eps], center = true);

        // Head (top), connected to neck with slight overlap
        translate([0, 0, neck_h + head_h/2 - eps/2])
            cube([head_w, nut_len, head_h + eps], center = true);
    }
}

difference() {
    tslot_nut_body();

    // Through clearance hole for M4 screw
    translate([0, 0, thickness/2])
        cylinder(h = thickness + 2*eps, d = screw_d + hole_clearance, center = true);

    // Hex socket (wrench size = across_flats) from TOP face down
    // Depth chosen to be clearly visible while keeping a solid bottom web.
    hex_depth = min(head_h - 0.25, thickness - 0.6);
    translate([0, 0, thickness - hex_depth/2])
        hex_prism_across_flats(across_flats + hex_clearance, hex_depth + 2*eps, center = true);
}
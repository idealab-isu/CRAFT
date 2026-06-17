// Linear bearing sleeve (plain envelope)
// Critical dimensions:
// - Bore:   16.0 mm
// - OD:     28.0 mm
// - Length: 37.0 mm
// One connected solid, no external grooves/reliefs.

$fn = 128;

// Parameters
bore_d  = 16.0;
outer_d = 28.0;
length  = 37.0;

// Small edge break (kept subtle; does not change critical dims)
edge_chamfer = 0.3;   // mm
overlap      = 0.5;   // mm (robust boolean)

// Derived
outer_r = outer_d/2;
bore_r  = bore_d/2;

// Base solids
module outer_body() {
    cylinder(h=length, r=outer_r, center=true);
}

module bore_cut() {
    cylinder(h=length + 2*overlap, r=bore_r, center=true);
}

// Internal edge chamfers only (keeps OD and length exact)
module inner_edge_chamfers() {
    // Clamp chamfer so it can't exceed wall thickness
    ch = min(edge_chamfer, max(0, (outer_r - bore_r) - 0.05));

    if (ch > 0) {
        // Top inner chamfer
        translate([0, 0, length/2 - ch/2])
            cylinder(h=ch + overlap,
                     r1=bore_r,
                     r2=bore_r + ch,
                     center=true);

        // Bottom inner chamfer
        translate([0, 0, -length/2 + ch/2])
            cylinder(h=ch + overlap,
                     r1=bore_r + ch,
                     r2=bore_r,
                     center=true);
    }
}

// Final model
module linear_bearing() {
    difference() {
        outer_body();
        bore_cut();
        inner_edge_chamfers();
    }
}

linear_bearing();
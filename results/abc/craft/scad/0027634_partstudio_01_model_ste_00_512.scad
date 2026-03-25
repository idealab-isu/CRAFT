// Concave-sided mounting plate with 4 circular through-holes,
// central cylindrical boss, and a small hexagonal protrusion on top.
// Single connected solid with guaranteed overlaps.

$fn = 96;

// ---------- Parameters (mm) ----------
plate_xy = 0.07;
plate_t  = 0.015;

concave_side_inset = 0.008;   // how far the concave arc bites into each side
concave_side_r     = 0.03;    // radius of the concave arc cutter

hole_d = 0.008;
hole_edge_margin = 0.01;

boss_d = 0.03;
boss_h = 0.02;

hex_af = 0.012;   // across flats
hex_h  = 0.005;

// Use a small overlap relative to this tiny part (not 1-2mm, which would dwarf it)
overlap = 0.001;

// ---------- Helpers ----------
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for a regular hex with given across-flats

module concave_plate_2d() {
    difference() {
        square([plate_xy, plate_xy], center=true);

        // Concave cuts on each side
        translate([ plate_xy/2 + concave_side_r - concave_side_inset, 0])
            circle(r=concave_side_r);
        translate([-plate_xy/2 - concave_side_r + concave_side_inset, 0])
            circle(r=concave_side_r);
        translate([0,  plate_xy/2 + concave_side_r - concave_side_inset])
            circle(r=concave_side_r);
        translate([0, -plate_xy/2 - concave_side_r + concave_side_inset])
            circle(r=concave_side_r);
    }
}

module plate_3d() {
    linear_extrude(height=plate_t, center=true)
        concave_plate_2d();
}

module corner_holes() {
    // Through-holes: extend beyond plate thickness to guarantee clean subtraction
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(plate_xy/2 - hole_edge_margin),
                   sy*(plate_xy/2 - hole_edge_margin),
                   0])
            cylinder(h=plate_t + 4*overlap, r=hole_d/2, center=true);
    }
}

module boss() {
    // Boss sits on top face of plate with overlap into plate for solid connection.
    // Plate top is at +plate_t/2. Boss bottom is set to (plate_t/2 - overlap).
    translate([0, 0, (plate_t/2 - overlap) + boss_h/2])
        cylinder(h=boss_h, r=boss_d/2, center=true);
}

module hex_drive() {
    // Hex protrusion on top face of boss with overlap into boss for solid connection.
    // Boss top is at (plate_t/2 - overlap + boss_h). Hex bottom is set to (boss_top - overlap).
    boss_top_z = (plate_t/2 - overlap) + boss_h;
    translate([0, 0, (boss_top_z - overlap) + hex_h/2])
        cylinder(h=hex_h, r=hex_R_from_AF(hex_af), $fn=6, center=true);
}

// ---------- Final solid ----------
difference() {
    union() {
        plate_3d();
        boss();
        hex_drive();   // ensure the requested hex drive feature is present and visible
    }
    corner_holes();
}
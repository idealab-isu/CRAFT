// Hex nut for M2 (2.0mm) screw
// Target: 4.9mm across flats, 1.6mm thick
// One connected solid (washer disabled by default)

$fn = 96;

// Parameters
thread_diameter_mm = 2.0;      // M2 major diameter (used for clearance hole unless threaded modeling is added)
across_flats_mm    = 4.9;      // across flats
thickness_mm       = 1.6;      // nut thickness
tolerance_mm       = 0.10;     // clearance on hole diameter
chamfer_mm         = 0.20;     // lead-in chamfer height
eps_mm             = 0.02;     // small epsilon for robust booleans

washer_enabled     = 0;        // keep off to ensure single connected solid by default
washer_outer_d_mm  = 5.5;
washer_thickness_mm= 0.5;

// Derived
hex_R = across_flats_mm / (2 * cos(30));                 // circumradius for $fn=6 cylinder
hole_r = (thread_diameter_mm + tolerance_mm) / 2;

module hex_nut() {
    difference() {
        // Body (not centered to avoid accidental "blank" from view/clipping issues)
        cylinder(h = thickness_mm, r = hex_R, $fn = 6, center = false);

        // Through hole
        translate([0, 0, -eps_mm])
            cylinder(h = thickness_mm + 2*eps_mm, r = hole_r, center = false);

        // Lead-in chamfers (top and bottom)
        // Bottom chamfer
        translate([0, 0, -eps_mm])
            cylinder(h = chamfer_mm + eps_mm,
                     r1 = hole_r + chamfer_mm,
                     r2 = hole_r,
                     center = false);

        // Top chamfer
        translate([0, 0, thickness_mm - chamfer_mm])
            cylinder(h = chamfer_mm + eps_mm,
                     r1 = hole_r,
                     r2 = hole_r + chamfer_mm,
                     center = false);
    }
}

module washer_connected() {
    // If enabled, fuse washer to nut with a tiny overlap so the result is ONE connected solid.
    if (washer_enabled) {
        overlap = 0.05;
        translate([0, 0, -(washer_thickness_mm - overlap)])
        difference() {
            cylinder(h = washer_thickness_mm, r = washer_outer_d_mm/2, center = false);
            translate([0, 0, -eps_mm])
                cylinder(h = washer_thickness_mm + 2*eps_mm, r = hole_r, center = false);
        }
    }
}

union() {
    hex_nut();
    washer_connected();
}
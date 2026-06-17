// Hex nut for 6.0mm screws, 11.5mm across flats, 3.0mm thick
// One connected solid (nut only)

// Parameters
thread_diameter_mm = 6.0;      // screw major diameter
across_flats_mm    = 11.5;     // AF
thickness_mm       = 3.0;      // nut thickness

hole_clearance_mm  = 0.4;      // clearance for screw
chamfer_mm         = 0.3;      // edge chamfer
eps_mm             = 0.02;     // small epsilon for robust booleans

// Derived
hex_R = across_flats_mm / sqrt(3);                 // circumradius for $fn=6 gives correct across-flats
hole_r = (thread_diameter_mm + hole_clearance_mm)/2;

module hex_nut() {
    difference() {
        // Outer hex prism
        cylinder(r=hex_R, h=thickness_mm, center=true, $fn=6);

        // Through hole
        cylinder(r=hole_r, h=thickness_mm + 2*eps_mm, center=true, $fn=64);

        // Top chamfer (remove material)
        translate([0, 0, thickness_mm/2 - chamfer_mm/2])
            cylinder(r1=hex_R + eps_mm, r2=max(hex_R - chamfer_mm, 0.01),
                     h=chamfer_mm + eps_mm, center=true, $fn=6);

        // Bottom chamfer (remove material)
        translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
            cylinder(r1=max(hex_R - chamfer_mm, 0.01), r2=hex_R + eps_mm,
                     h=chamfer_mm + eps_mm, center=true, $fn=6);
    }
}

hex_nut();
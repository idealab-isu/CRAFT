// Hex nut for 4.0mm screws: 5.3mm across flats, 6.3mm thick

// Parameters
thread_nominal_diameter_mm = 4.0; //[2.0:8.0:0.1]
across_flats_mm = 5.3; //[2.65:10.6:0.1]
thickness_mm = 6.3; //[3.15:12.6:0.1]
clearance_diameter_mm = 4.2; //[3.5:5.5:0.05]
tap_drill_diameter_mm = 3.3; //[2.5:4.5:0.05]
tolerance_mm = 0.1; //[0.0:0.5:0.01]
hole_type_selector = 0; //[0:1:1]  // 0=clearance, 1=tap drill
chamfer_mm = 0.3; //[0.0:1.0:0.05]
chamfer_enable = 1; //[0:1:1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
washer_enable = 0; //[0:1:1]
washer_outer_diameter_mm = 9.0; //[6.0:18.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]

function hole_r() =
    ((1 - hole_type_selector) * (clearance_diameter_mm / 2)
   + (hole_type_selector)     * (tap_drill_diameter_mm / 2))
   + tolerance_mm / 2;

function hex_R_from_flats(af) = af / sqrt(3); // circumradius for a hex with across-flats = af

module hex_prism(af, h, center=true) {
    // No rotation needed: with $fn=6, flats are aligned to X/Y axes.
    cylinder(r=hex_R_from_flats(af), h=h, center=center, $fn=6);
}

module nut() {
    R = hex_R_from_flats(across_flats_mm);

    difference() {
        // Main hex body
        hex_prism(across_flats_mm, thickness_mm, center=true);

        // Through hole
        cylinder(r=hole_r(), h=thickness_mm + 2*overlap_mm, center=true, $fn=64);

        // Chamfers (remove material at top and bottom edges)
        if (chamfer_enable && chamfer_mm > 0) {
            // Top chamfer cutter
            translate([0, 0, thickness_mm/2 - chamfer_mm/2])
                cylinder(r1=R + chamfer_mm, r2=R, h=chamfer_mm + overlap_mm, center=true, $fn=6);

            // Bottom chamfer cutter
            translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
                cylinder(r1=R, r2=R + chamfer_mm, h=chamfer_mm + overlap_mm, center=true, $fn=6);
        }
    }
}

module nut_and_washer() {
    union() {
        nut();

        if (washer_enable) {
            // Washer is connected to nut with a small overlap
            translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)])
                difference() {
                    cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=96);
                    cylinder(r=hole_r(), h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=64);
                }
        }
    }
}

nut_and_washer();
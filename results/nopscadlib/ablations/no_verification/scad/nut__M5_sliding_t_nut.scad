$fn = 80;

// Target: T-slot nut for 5.0mm screws, 6.0mm across flats, 3.7mm thick
screw_nominal_diameter_mm = 5.0;
internal_drive_across_flats_mm = 6.0;
thickness_mm = 3.7;

// Fit/print params
tolerance_mm = 0.2;
threaded = 1; // 1=tap drill (for threading), 0=clearance
clearance_hole_diameter_mm = 5.5;
tap_drill_diameter_mm = 4.2;

// Body params (typical small T-nut proportions; adjust if needed)
body_length_mm = 16;
t_major_width_mm = 13;   // wide part that captures under slot lips
t_minor_width_mm = 8;    // neck width that passes through slot opening

// Optional small edge break
edge_chamfer_mm = 0.3;

// Internal hex drive depth (recess)
drive_depth_mm = 2.2;

// Robust boolean overlap
overlap_mm = 0.6;

// ---------- helpers ----------
function hex_circumradius_from_af(af) = af / (2 * cos(30)); // across flats -> circumradius

module hex_prism(af, h, center=false) {
    // true hex (not a circle approximation)
    cylinder(h=h, r=hex_circumradius_from_af(af), $fn=6, center=center);
}

module tslot_nut() {
    hole_d = (threaded > 0.5) ? tap_drill_diameter_mm : clearance_hole_diameter_mm;
    hex_af = internal_drive_across_flats_mm + tolerance_mm;

    difference() {
        // ONE connected solid: a simple T-profile prism (major + minor) fused
        union() {
            // Major (under-lip) block
            cube([body_length_mm, t_major_width_mm, thickness_mm], center=true);

            // Minor (neck) block - centered, same thickness, narrower
            cube([body_length_mm, t_minor_width_mm, thickness_mm], center=true);
        }

        // Through hole for M5 (tap drill or clearance)
        cylinder(h=thickness_mm + 2*overlap_mm, d=hole_d + tolerance_mm, center=true);

        // Internal hex drive recess from top face
        translate([0, 0, thickness_mm/2 - drive_depth_mm])
            hex_prism(hex_af, drive_depth_mm + overlap_mm, center=false);

        // Small edge chamfers on the long edges (optional, subtle)
        // Cut 45° wedges along the two long sides of the major width
        for (sy = [-1, 1]) {
            translate([0,
                       sy*(t_major_width_mm/2 - edge_chamfer_mm/2),
                       0])
                rotate([0, 0, 45])
                    cube([body_length_mm + 2*overlap_mm,
                          edge_chamfer_mm,
                          thickness_mm + 2*overlap_mm],
                         center=true);
        }
    }
}

tslot_nut();
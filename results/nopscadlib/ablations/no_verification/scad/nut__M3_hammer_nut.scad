// T-slot nut for M3 screw, 6.0mm across flats, 2.75mm thick
// One connected solid (nut body only), with a centered M3 clearance hole.

$fn = 80;

// Parameters (mm)
screw_diameter_mm        = 3.0;
hole_clearance_mm        = 0.30;   // clearance for M3
outer_across_flats_mm    = 6.0;    // hex across flats
thickness_mm             = 2.75;   // overall thickness
chamfer_mm               = 0.20;   // small lead-in on both faces
eps_mm                   = 0.02;

// Simple T-slot slider features (kept connected and within thickness)
retention_length_mm      = 10.0;   // along X
neck_width_mm            = 5.8;    // narrow section width (Y)
retention_width_mm       = 7.8;    // wider step width (Y)
retention_step_height_mm = 1.20;   // step height (Z)
overlap_mm               = 0.20;   // overlap to guarantee manifold unions

function hex_circumradius_from_af(af) = af / (2 * cos(30)); // R such that across-flats = af

module tslot_nut() {
    R_hex = hex_circumradius_from_af(outer_across_flats_mm);
    hole_r = (screw_diameter_mm + hole_clearance_mm) / 2;

    difference() {
        // ONE connected solid: hex nut + retention slider profile
        union() {
            // Hex body
            cylinder(r=R_hex, h=thickness_mm, center=true, $fn=6);

            // Neck block (centered, same thickness)
            cube([retention_length_mm, neck_width_mm, thickness_mm], center=true);

            // Wider retention step on the bottom face (connected by overlap)
            translate([0, 0, -thickness_mm/2 + retention_step_height_mm/2 - overlap_mm])
                cube([retention_length_mm, retention_width_mm, retention_step_height_mm], center=true);
        }

        // Central through-hole for M3
        cylinder(r=hole_r, h=thickness_mm + 2*eps_mm, center=true);

        // Lead-in chamfers (top and bottom) around the hole
        translate([0, 0,  thickness_mm/2 - chamfer_mm/2 + eps_mm])
            cylinder(r1=hole_r + chamfer_mm, r2=hole_r, h=chamfer_mm + 2*eps_mm, center=true);

        translate([0, 0, -thickness_mm/2 + chamfer_mm/2 - eps_mm])
            cylinder(r1=hole_r, r2=hole_r + chamfer_mm, h=chamfer_mm + 2*eps_mm, center=true);
    }
}

tslot_nut();
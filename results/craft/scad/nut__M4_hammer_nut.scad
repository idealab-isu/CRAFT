// Parameters
screw_nominal_diameter_mm = 4.0; //[2.0:8.0:0.1]
nut_across_flats_mm = 6.0; //[3.0:12.0:0.1]
nut_thickness_mm = 3.25; //[1.6:6.5:0.05]
hole_type_threaded = 1; //[0:1:1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]  // (not modeled; drill/tap only)
clearance_hole_diameter_mm_if_unthreaded = 4.3; //[4.0:5.0:0.05]
tap_drill_diameter_mm_for_threaded = 3.3; //[2.5:4.0:0.05]
edge_chamfer_mm = 0.2; //[0.0:0.8:0.05]
fit_clearance_mm = 0.2; //[0.0:0.6:0.05]
t_slot_width_mm = 8.0; //[4.0:16.0:0.1]
t_slot_lip_thickness_mm = 1.5; //[0.8:3.0:0.1]
t_slot_depth_mm = 6.0; //[3.0:12.0:0.1]
shoulder_height_mm = 0.8; //[0.4:1.6:0.05]
shoulder_overhang_mm = 0.8; //[0.3:2.0:0.05]
shoulder_length_mm = 4.5; //[2.0:10.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Quality
$fn = 64;

// Helpers
function hex_R_from_AF(af) = af/(2*cos(30)); // circumradius for a hex with across-flats = af

module hex_prism(af, h, center=true) {
    cylinder(r=hex_R_from_AF(af), h=h, center=center, $fn=6);
}

module chamfered_hex(af, h, chamfer) {
    // Chamfered by subtracting two 45° cones from top/bottom edges
    difference() {
        hex_prism(af, h, center=true);

        if (chamfer > 0) {
            // Top chamfer
            translate([0,0, h/2 - chamfer/2])
                cylinder(h=chamfer + overlap_mm,
                         r1=hex_R_from_AF(af) + chamfer,
                         r2=hex_R_from_AF(af) - 0.01,
                         center=true, $fn=6);

            // Bottom chamfer
            translate([0,0,-h/2 + chamfer/2])
                cylinder(h=chamfer + overlap_mm,
                         r1=hex_R_from_AF(af) - 0.01,
                         r2=hex_R_from_AF(af) + chamfer,
                         center=true, $fn=6);
        }
    }
}

// M4 T-slot / hammer nut (single connected solid with a through-hole)
module M4_hammer_nut() {
    // Body dimensions (typical hammer nut: rectangular bar with two retention shoulders)
    body_len_mm = max(shoulder_length_mm + 2.0, t_slot_width_mm - 0.5); // along X
    body_w_mm   = max(nut_across_flats_mm + 1.0, t_slot_width_mm - 0.8); // along Y
    body_h_mm   = nut_thickness_mm;

    // Shoulders: small ledges near the top that catch under the T-slot lips
    shoulder_w_mm = max(0.6, t_slot_lip_thickness_mm + fit_clearance_mm); // along Y (each side)
    shoulder_len_mm = min(body_len_mm, shoulder_length_mm);
    shoulder_h_mm = min(shoulder_height_mm, body_h_mm * 0.6);

    // Place shoulders at the top face, protruding outward in +/-Y
    shoulder_z = body_h_mm/2 - shoulder_h_mm/2 + overlap_mm/2;
    shoulder_y = body_w_mm/2 + shoulder_w_mm/2 - overlap_mm; // overlap into body for connectivity

    // Hole diameter (modeled as drill/tap hole or clearance hole)
    hole_d = (hole_type_threaded == 1) ? tap_drill_diameter_mm_for_threaded
                                       : clearance_hole_diameter_mm_if_unthreaded;

    difference() {
        union() {
            // Main rectangular hammer-nut body
            translate([0,0,0])
                cube([body_len_mm, body_w_mm, body_h_mm], center=true);

            // Retention shoulders (connected via calculated overlap)
            translate([0,  shoulder_y, shoulder_z])
                cube([shoulder_len_mm, shoulder_w_mm, shoulder_h_mm], center=true);

            translate([0, -shoulder_y, shoulder_z])
                cube([shoulder_len_mm, shoulder_w_mm, shoulder_h_mm], center=true);

            // Optional small top chamfered hex boss to show 6mm across-flats feature
            // (kept low so overall thickness remains nut_thickness_mm)
            boss_h = min(1.2, body_h_mm - 0.4);
            boss_z = body_h_mm/2 - boss_h/2 - 0.0; // sits on top face
            translate([0,0,boss_z])
                chamfered_hex(nut_across_flats_mm, boss_h, min(edge_chamfer_mm, boss_h/2 - 0.01));
        }

        // Through-hole for M4 screw (tap drill or clearance)
        cylinder(d=hole_d, h=body_h_mm + 2*overlap_mm, center=true);

        // Light edge chamfer on the hole (both sides) for printability
        if (edge_chamfer_mm > 0) {
            translate([0,0, body_h_mm/2 - edge_chamfer_mm/2])
                cylinder(h=edge_chamfer_mm + overlap_mm,
                         d1=hole_d + 2*edge_chamfer_mm,
                         d2=hole_d,
                         center=true);

            translate([0,0,-body_h_mm/2 + edge_chamfer_mm/2])
                cylinder(h=edge_chamfer_mm + overlap_mm,
                         d1=hole_d,
                         d2=hole_d + 2*edge_chamfer_mm,
                         center=true);
        }
    }
}

M4_hammer_nut();
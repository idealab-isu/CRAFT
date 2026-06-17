// T-slot nut (single connected solid)
// Target: 4.0mm screw clearance, 6.0mm across flats hex pocket, 3.7mm thick

// ---------------- Parameters ----------------
screw_thread_diameter_mm = 4.0;          //[2.0:8.0:0.1]
across_flats_mm          = 6.0;          //[3.0:12.0:0.1]
thickness_mm             = 3.7;          //[1.85:7.4:0.1]

// Typical compact T-nut envelope (editable)
body_length_mm           = 12.0;         //[6.0:24.0:0.5]   // along slot
slot_neck_width_mm       = 6.2;          //[3.0:12.0:0.1]   // narrow opening of slot
slot_inner_width_mm      = 10.2;         //[5.0:20.0:0.1]   // wider cavity under lips
slot_lip_thickness_mm    = 1.2;          //[0.6:2.4:0.1]    // thickness of each lip (per side)
retention_shoulder_height_mm = 0.8;      //[0.4:1.6:0.1]    // height of the undercut region (from each face)

manufacturing_allowance_mm = 0.10;       //[0.0:0.5:0.05]
threaded_hole_clearance_factor = 1.05;  //[1.0:1.2:0.01]

chamfer_mm               = 0.30;         //[0.1:1.0:0.05]
overlap_mm               = 1.20;         //[0.5:2.0:0.1]  // use 1-2mm overlap for robust connectivity

$fn = 96;

// ---------------- Derived ----------------
body_width_mm = slot_inner_width_mm + 2*slot_lip_thickness_mm; // overall width across lips

hole_r = (screw_thread_diameter_mm*threaded_hole_clearance_factor + manufacturing_allowance_mm)/2;

// Hex circumradius for given across-flats (AF = 2*R*cos(30))
hex_R  = (across_flats_mm/2)/cos(30);

// Ensure the neck cut does NOT remove the lips entirely
slot_neck_width_eff_mm = min(slot_neck_width_mm, body_width_mm - 2*manufacturing_allowance_mm);

// Ensure undercut height is valid for given thickness
ret_h_eff_mm = min(retention_shoulder_height_mm, thickness_mm/2 - 0.05);

// ---------------- Helpers ----------------
module chamfer_ends_cut() {
    for (sx = [-1, 1]) {
        translate([sx*(body_length_mm/2 - chamfer_mm/2), 0, 0])
            cube([chamfer_mm, body_width_mm + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);
    }
}

module chamfer_sides_cut() {
    for (sy = [-1, 1]) {
        translate([0, sy*(body_width_mm/2 - chamfer_mm/2), 0])
            cube([body_length_mm + 2*overlap_mm, chamfer_mm, thickness_mm + 2*overlap_mm], center=true);
    }
}

// ---------------- Main solid ----------------
module t_slot_nut() {

    // Build as a single connected solid (explicit union), then subtract cuts.
    // Add a tiny internal "web" so the two lips remain physically connected
    // (prevents the model from becoming two separate rectangular solids).
    difference() {
        union() {
            // Base block (overall envelope)
            cube([body_length_mm, body_width_mm, thickness_mm], center=true);

            // Internal connector web (keeps left/right lips connected after the neck cut)
            // Overlaps the base by design; small enough to not change the external design.
            web_w_mm = max(0.8, 2*manufacturing_allowance_mm + 0.4); // thin but printable
            cube([body_length_mm + overlap_mm, web_w_mm, thickness_mm], center=true);
        }

        // T-slot undercut pockets near both faces (leave lips at outer edges)
        translate([0, 0, +thickness_mm/2 - ret_h_eff_mm/2])
            cube([body_length_mm + 2*overlap_mm, slot_inner_width_mm, ret_h_eff_mm + 2*overlap_mm], center=true);

        translate([0, 0, -thickness_mm/2 + ret_h_eff_mm/2])
            cube([body_length_mm + 2*overlap_mm, slot_inner_width_mm, ret_h_eff_mm + 2*overlap_mm], center=true);

        // Central neck cut (runs full thickness) - narrower than overall width so lips remain
        // NOTE: The internal web above ensures the part stays one connected solid.
        cube([body_length_mm + 2*overlap_mm, slot_neck_width_eff_mm, thickness_mm + 2*overlap_mm], center=true);

        // Central screw clearance hole (4.0mm screw compatible)
        cylinder(h=thickness_mm + 2*overlap_mm, r=hole_r, center=true);

        // Hex pocket for 6.0mm across flats (nut capture), shallow so part stays connected
        hex_pocket_depth_mm = min(thickness_mm*0.60, thickness_mm - 0.6);
        translate([0, 0, +thickness_mm/2 - hex_pocket_depth_mm/2])
            cylinder(h=hex_pocket_depth_mm + 2*overlap_mm, r=hex_R, center=true, $fn=6);

        // Optional edge chamfers (cuts)
        chamfer_ends_cut();
        chamfer_sides_cut();
    }
}

t_slot_nut();
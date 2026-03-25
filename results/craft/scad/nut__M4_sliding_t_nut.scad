$fn = 80;

// Requested key dimensions
screw_nominal_diameter_mm = 4.0;          // M4
across_flats_mm           = 6.0;          // hex pocket AF
thickness_mm              = 3.7;          // overall nut thickness

// Typical sliding T-slot nut proportions (parametric)
nut_overall_length_mm = 12.0;
nut_overall_width_mm  = 9.6;

// Slot interface (adjust to your extrusion/slot)
t_slot_neck_width_mm  = 6.0;              // neck opening
lip_thickness_mm      = 0.8;              // each lip thickness
lip_width_extra_mm    = 1.2;              // lips wider than neck by this amount (total)
tolerances_mm         = 0.2;              // fit allowance

// Hole sizing
tap_drill_diameter_mm       = 3.3;        // for M4 tapping
clearance_hole_diameter_mm  = 4.3;
use_clearance_hole          = 0;          // 0=tap drill, 1=clearance
effective_hole_diameter_mm  = use_clearance_hole ? clearance_hole_diameter_mm : tap_drill_diameter_mm;

// Detailing
entry_chamfer_mm  = 0.6;
corner_chamfer_mm = 0.3;
overlap_mm        = 0.6;

// Helpers
function hex_radius_from_af(af) = af / sqrt(3); // circumradius for a hex with given across-flats

module hex2d(af){
    r = hex_radius_from_af(af);
    polygon([ for (i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module tslot_nut(){
    // Lip width (in Y) that engages the slot undercut
    lip_w = max(t_slot_neck_width_mm, t_slot_neck_width_mm + lip_width_extra_mm - tolerances_mm);

    // Body width must be >= lip width so lips are not "floating" outside the body
    body_w = max(nut_overall_width_mm, lip_w);

    // Ensure lips do not exceed thickness
    lip_t = min(lip_thickness_mm, thickness_mm/2 - 0.05);

    // Main solid (single connected body)
    difference(){
        union(){
            // Main rectangular body
            cube([nut_overall_length_mm, body_w, thickness_mm], center=true);

            // Retention lips: make them slightly thicker than lip_t and overlap into body
            // so they are guaranteed connected and not coplanar artifacts.
            lip_h = lip_t + overlap_mm;

            translate([0, 0,  thickness_mm/2 - lip_t/2])
                cube([nut_overall_length_mm, lip_w, lip_h], center=true);

            translate([0, 0, -thickness_mm/2 + lip_t/2])
                cube([nut_overall_length_mm, lip_w, lip_h], center=true);
        }

        // Central through-hole for M4 (tap drill or clearance)
        cylinder(d=effective_hole_diameter_mm, h=thickness_mm + 2*overlap_mm, center=true);

        // Hex pocket on the TOP face (across flats = 6.0mm)
        // Keep some material under the pocket.
        min_floor = 0.8;
        hex_depth = max(0.6, min(thickness_mm - min_floor, thickness_mm*0.55));
        translate([0, 0, thickness_mm/2 - hex_depth/2])
            linear_extrude(height=hex_depth + overlap_mm, center=true)
                hex2d(across_flats_mm + 0.15);

        // End chamfers (computed placement; no arbitrary offsets)
        chamfer_len = min(entry_chamfer_mm, nut_overall_length_mm/4);

        translate([ nut_overall_length_mm/2 - chamfer_len/2, 0, 0])
            rotate([0, 45, 0])
                cube([chamfer_len, body_w + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);

        translate([-nut_overall_length_mm/2 + chamfer_len/2, 0, 0])
            rotate([0,-45, 0])
                cube([chamfer_len, body_w + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);

        // Small edge breaks (top/bottom) - keep subtle to avoid slicing the body into artifacts
        edge_break = min(corner_chamfer_mm, thickness_mm/4);
        translate([0, 0,  thickness_mm/2 - edge_break/2])
            rotate([45, 0, 0])
                cube([nut_overall_length_mm + 2*overlap_mm, body_w + 2*overlap_mm, edge_break], center=true);

        translate([0, 0, -thickness_mm/2 + edge_break/2])
            rotate([-45, 0, 0])
                cube([nut_overall_length_mm + 2*overlap_mm, body_w + 2*overlap_mm, edge_break], center=true);
    }
}

tslot_nut();
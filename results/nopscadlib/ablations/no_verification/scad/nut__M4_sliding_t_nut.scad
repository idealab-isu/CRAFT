// T-slot nut (standalone) for 4.0mm screw, 6.0mm across flats, 3.7mm thick

// Parameters
screw_diameter_mm = 4; //[2:8:0.1]
across_flats_mm = 6; //[3:12:0.1]
thickness_mm = 3.7; //[1.85:7.4:0.1]
hole_style_is_clearance = 1; //[0:1:1]
clearance_diameter_mm = 4.3; //[4:6:0.05]
tap_drill_diameter_mm = 3.3; //[2.5:4:0.05]
t_slot_width_mm = 8; //[4:16:0.1]
t_slot_depth_mm = 6; //[3:12:0.1]
t_slot_lip_thickness_mm = 1.5; //[0.75:3:0.1]
retention_undercut_mm = 1; //[0.5:2:0.1]
retention_foot_height_mm = 1.2; //[0.6:2.4:0.1]
retention_neck_height_mm = 2.2; //[1.1:4.4:0.1]
nut_length_mm = 12; //[6:24:0.5]
chamfer_mm = 0.3; //[0.1:1:0.05]
connection_overlap_mm = 0.8; //[0.5:2:0.1]
hole_extra_height_mm = 2; //[1:6:0.5]

$fn = 96;

module hex_prism_af(af, h, center=true) {
    // Regular hex with given across-flats (AF)
    // For a regular hex: AF = 2 * apothem; circumradius R = AF / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6, center=center);
}

module tslot_nut() {
    core_af = across_flats_mm;     // hex across flats
    core_l  = nut_length_mm;
    core_h  = thickness_mm;

    // T-slot engagement widths
    foot_w = t_slot_width_mm;
    neck_w = max(0.1, t_slot_width_mm - 2 * retention_undercut_mm);

    // Heights: keep within thickness
    foot_h = min(retention_foot_height_mm, core_h);
    neck_h = min(retention_neck_height_mm, max(0, core_h - foot_h));

    // Z placement (all connected, with overlap)
    z_bottom = -core_h/2;
    z_foot_c = z_bottom + foot_h/2;
    z_neck_c = z_bottom + foot_h + neck_h/2 - connection_overlap_mm/2;

    // Hole diameter
    hole_d = hole_style_is_clearance ? clearance_diameter_mm : tap_drill_diameter_mm;

    // Optional top counterbore for a 6mm AF captive nut form (hex pocket)
    // Depth limited so it doesn't break through.
    hex_pocket_depth = min(core_h * 0.70, core_h - 0.4); // leave at least 0.4mm floor
    hex_pocket_depth = max(0, hex_pocket_depth);
    z_hex_pocket_c = core_h/2 - hex_pocket_depth/2;

    // Simple chamfer via minkowski (kept small to avoid heavy compute)
    // Use only if chamfer_mm > 0
    module body_solid() {
        union() {
            // Main hex body (6mm AF)
            rotate([0, 0, 30])  // orient flats horizontally/vertically
                linear_extrude(height=core_l, center=true, convexity=10)
                    circle(r=(core_af/sqrt(3)), $fn=6);

            // Retention foot (bottom, wider)
            translate([0, 0, z_foot_c])
                cube([foot_w, core_l, foot_h], center=true);

            // Retention neck (above foot, narrower), overlaps for connectivity
            if (neck_h > 0)
                translate([0, 0, z_neck_c])
                    cube([neck_w, core_l, neck_h], center=true);
        }
    }

    difference() {
        if (chamfer_mm > 0) {
            // Chamfer/edge break while staying one connected solid
            minkowski() {
                body_solid();
                // small sphere gives uniform edge rounding/chamfer-like break
                sphere(r=chamfer_mm, $fn=24);
            }
        } else {
            body_solid();
        }

        // Through-hole for M4 (clearance or tap drill)
        cylinder(h=core_h + hole_extra_height_mm, d=hole_d, center=true);

        // Hex pocket (6mm AF) on top face for screw interface (captured nut/driver)
        if (hex_pocket_depth > 0)
            translate([0, 0, z_hex_pocket_c])
                rotate([0, 0, 30])
                    hex_prism_af(core_af, hex_pocket_depth + 0.2, center=true);
    }
}

tslot_nut();
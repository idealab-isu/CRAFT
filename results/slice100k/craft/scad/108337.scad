$fn = 128;

// -------------------- Parameters (mm) --------------------
bbox_L = 46.2;
bbox_W = 40.0;
bbox_H = 8.0;

plate_thickness = bbox_H;

// Hex size (flat-to-flat). Use major as controlling; minor achieved by anisotropic scale.
hex_flat_to_flat_major = bbox_L;
hex_flat_to_flat_minor = bbox_W;

// Through-hole
hole_d = 8.0;
hole_offset_x = 0;
hole_offset_y = 0;

// Two shallow, parallel diagonal grooves on ONE face (top)
groove_width     = 2.2;
groove_depth     = 0.8;
groove_spacing   = 4.0;
groove_angle_deg = 30;

// Perimeter step-like thickness change (top face recess band)
step_outer_band_w = 2.0;   // band width from outer edge inward
step_height_drop  = 1.0;   // recess depth from top face

// Small edge chamfer (kept subtle)
edge_chamfer = 0.6;

eps = 0.02;     // small epsilon for robust booleans
overlap = 1.2;  // ensure cutters fully intersect (1-2mm)

// -------------------- Helpers --------------------
function hex_R_from_flat(flat) = flat / sqrt(3); // circumradius for a regular hex given flat-to-flat

module hex2d_from_flat(flat) {
    polygon(points=[
        for (i=[0:5])
            let(a = 60*i)
            [hex_R_from_flat(flat)*cos(a), hex_R_from_flat(flat)*sin(a)]
    ]);
}

module scaled_hex_prism(flat_major, flat_minor, h, center=true) {
    scale([1, flat_minor/flat_major, 1])
        linear_extrude(height=h, center=center)
            hex2d_from_flat(flat_major);
}

// -------------------- Feature cutters --------------------
module through_hole() {
    translate([hole_offset_x, hole_offset_y, 0])
        cylinder(d=hole_d, h=plate_thickness + 2*overlap, center=true);
}

module top_perimeter_step_recess() {
    // Cut a shallow "ring" recess on the TOP face.
    inner_flat_major = hex_flat_to_flat_major - 2*step_outer_band_w;
    inner_flat_minor = hex_flat_to_flat_minor - 2*step_outer_band_w;

    inner_flat_major_ok = max(inner_flat_major, 0.1);
    inner_flat_minor_ok = max(inner_flat_minor, 0.1);

    // Place recess so its TOP is flush with the plate top face
    translate([0, 0, plate_thickness/2 - step_height_drop/2])
        linear_extrude(height=step_height_drop + 2*eps, center=true)
            difference() {
                // Outer boundary matches the plate outline (same squash ratio)
                scale([1, hex_flat_to_flat_minor/hex_flat_to_flat_major, 1])
                    hex2d_from_flat(hex_flat_to_flat_major);

                // Inner boundary uses the SAME squash ratio as the plate
                // (fixes the "invisible/odd" step band caused by mismatched scaling)
                scale([1, hex_flat_to_flat_minor/hex_flat_to_flat_major, 1])
                    hex2d_from_flat(inner_flat_major_ok);
            }
}

module diagonal_groove(yoff) {
    // Long rounded slot, shallow, cut into TOP face.
    slot_len = bbox_L + 20; // ensure it spans the part with margin

    translate([0, yoff, plate_thickness/2 - groove_depth/2])
        rotate([0, 0, groove_angle_deg])
            linear_extrude(height=groove_depth + 2*eps, center=true)
                hull() {
                    translate([ slot_len/2 - groove_width/2, 0])
                        circle(d=groove_width);
                    translate([-slot_len/2 + groove_width/2, 0])
                        circle(d=groove_width);
                }
}

module edge_chamfer_cutters() {
    // Subtract tapered extrusions at top and bottom to create subtle chamfers.
    chamfer_scale = max(0.90, 1 - (2*edge_chamfer)/max(hex_flat_to_flat_major, 1));

    // Top chamfer cutter
    translate([0, 0, plate_thickness/2 - edge_chamfer/2])
        scale([1, hex_flat_to_flat_minor/hex_flat_to_flat_major, 1])
            linear_extrude(height=edge_chamfer + 2*overlap, center=true, scale=chamfer_scale)
                hex2d_from_flat(hex_flat_to_flat_major);

    // Bottom chamfer cutter
    translate([0, 0, -plate_thickness/2 + edge_chamfer/2])
        scale([1, hex_flat_to_flat_minor/hex_flat_to_flat_major, 1])
            linear_extrude(height=edge_chamfer + 2*overlap, center=true, scale=chamfer_scale)
                hex2d_from_flat(hex_flat_to_flat_major);
}

// -------------------- Final geometry --------------------
union() {
    difference() {
        // Main body: flat hexagonal plate (squashed to match bbox)
        scaled_hex_prism(hex_flat_to_flat_major, hex_flat_to_flat_minor, plate_thickness, center=true);

        // Through-hole
        through_hole();

        // Perimeter step-like thickness change (top face recess band)
        top_perimeter_step_recess();

        // Two shallow, parallel diagonal grooves on top face (visible recessed lines)
        diagonal_groove( groove_spacing/2);
        diagonal_groove(-groove_spacing/2);

        // Small edge chamfers
        edge_chamfer_cutters();
    }
}
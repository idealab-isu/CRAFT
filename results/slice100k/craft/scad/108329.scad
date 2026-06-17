// Fixed OpenSCAD model: thick hex plate with visible through-hole,
// clear perimeter steps/notches, and asymmetric top/bottom reliefs.
// Ensures ONE connected solid and non-blank render by using consistent centering.

// ---------- Parameters ----------
bbox_x = 46.19;                 // target overall X (approx, via hex corners)
bbox_y = 40.0;                  // target overall Y (flat-to-flat)
thickness_z = 19.0;             // overall thickness

hex_flat_to_flat = 40.0;        // across flats (Y direction when point-up)
hex_rotation_deg = 0.0;

hole_d = 6.0;
hole_offset_x = 1.5;
hole_offset_y = -0.8;

notch_count = 6;
notch_w = 6.0;                  // tangential width
notch_d = 2.0;                  // radial depth into perimeter
notch_h = 4.0;                  // vertical height of notch cut
notch_z_from_top = 0.0;         // 0 => starts at top surface

top_relief_1_w = 18.0;
top_relief_1_d = 8.0;
top_relief_1_depth = 3.0;
top_relief_1_offset_x = 6.0;
top_relief_1_offset_y = 0.0;

top_relief_2_w = 10.0;
top_relief_2_d = 6.0;
top_relief_2_depth = 2.0;
top_relief_2_offset_x = -8.0;
top_relief_2_offset_y = 6.0;

bottom_relief_1_w = 16.0;
bottom_relief_1_d = 10.0;
bottom_relief_1_depth = 3.0;
bottom_relief_1_offset_x = -5.0;
bottom_relief_1_offset_y = -4.0;

bottom_relief_2_w = 9.0;
bottom_relief_2_d = 7.0;
bottom_relief_2_depth = 2.0;
bottom_relief_2_offset_x = 7.0;
bottom_relief_2_offset_y = -7.0;

edge_chamfer_size = 0.8;        // small corner reliefs (optional)
alignment_mark_d = 2.0;
alignment_mark_depth = 0.6;
alignment_mark_offset_r = 14.0;

overlap = 1.0;

countersink_enable = 0;
countersink_top_d = 10.0;
countersink_depth = 3.0;

// ---------- Derived ----------
hex_apothem = hex_flat_to_flat/2;                 // center to flat
hex_corner_r = hex_flat_to_flat/sqrt(3);          // center to corner (circumradius)

// ---------- Helpers ----------
module hex_prism(ftf, h, rot=0) {
    // Use cylinder with $fn=6 for robust, centered hex prism.
    // For a regular hex: across flats = sqrt(3)*R => R = ftf/sqrt(3)
    rotate([0,0,rot])
        cylinder(h=h, r=ftf/sqrt(3), $fn=6, center=true);
}

module through_hole() {
    translate([hole_offset_x, hole_offset_y, 0])
        cylinder(h=thickness_z + 2*overlap, r=hole_d/2, center=true, $fn=64);
}

module perimeter_notch(angle_deg) {
    // Cut a shallow rectangular step into each flat, near the perimeter.
    // Place the notch so its outer face slightly exceeds the flat plane to guarantee intersection.
    // Flat plane is at radius = hex_apothem.
    rotate([0,0,angle_deg])
        translate([hex_apothem - notch_d/2 + overlap/2, 0,
                   thickness_z/2 - notch_z_from_top - notch_h/2])
            cube([notch_d + overlap, notch_w, notch_h + overlap], center=true);
}

module top_relief(w,d,depth,ox,oy) {
    translate([ox, oy, thickness_z/2 - depth/2])
        cube([w, d, depth + overlap], center=true);
}

module bottom_relief(w,d,depth,ox,oy) {
    translate([ox, oy, -thickness_z/2 + depth/2])
        cube([w, d, depth + overlap], center=true);
}

module edge_corner_relief(angle_deg) {
    // Small corner reliefs near vertices to suggest chamfer/relief without complex minkowski.
    rotate([0,0,angle_deg])
        translate([hex_corner_r - edge_chamfer_size/2 + overlap/2, 0, 0])
            cube([edge_chamfer_size + overlap, edge_chamfer_size + overlap, thickness_z + 2*overlap], center=true);
}

module alignment_mark(angle_deg) {
    rotate([0,0,angle_deg])
        translate([alignment_mark_offset_r, 0, thickness_z/2 - alignment_mark_depth/2])
            cylinder(r=alignment_mark_d/2, h=alignment_mark_depth + overlap, center=true, $fn=48);
}

module countersink_variant() {
    if (countersink_enable) {
        translate([hole_offset_x, hole_offset_y, thickness_z/2 - countersink_depth/2])
            cylinder(r1=countersink_top_d/2, r2=hole_d/2, h=countersink_depth + overlap, center=true, $fn=64);
    }
}

// ---------- Complete Model ----------
module complete_model() {
    difference() {
        // Main body centered at origin to match all subtractive features
        hex_prism(hex_flat_to_flat, thickness_z, hex_rotation_deg);

        union() {
            // Central through-hole (now correctly centered in Z and guaranteed to cut through)
            through_hole();

            // Perimeter notches/steps around flats
            for (i = [0:notch_count-1])
                perimeter_notch(i * 360/notch_count);

            // Asymmetric top reliefs (cuts)
            top_relief(top_relief_1_w, top_relief_1_d, top_relief_1_depth, top_relief_1_offset_x, top_relief_1_offset_y);
            top_relief(top_relief_2_w, top_relief_2_d, top_relief_2_depth, top_relief_2_offset_x, top_relief_2_offset_y);

            // Asymmetric bottom reliefs (different from top)
            bottom_relief(bottom_relief_1_w, bottom_relief_1_d, bottom_relief_1_depth, bottom_relief_1_offset_x, bottom_relief_1_offset_y);
            bottom_relief(bottom_relief_2_w, bottom_relief_2_d, bottom_relief_2_depth, bottom_relief_2_offset_x, bottom_relief_2_offset_y);

            // Small corner reliefs at vertices (optional but helps stepped/keyed look)
            for (i = [0:5])
                edge_corner_relief(i * 60 + 30); // vertices for point-up hex

            // Small alignment marks on top face
            alignment_mark(0);
            alignment_mark(210);

            // Optional countersink
            countersink_variant();
        }
    }
}

complete_model();
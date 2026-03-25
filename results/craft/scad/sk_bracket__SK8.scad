$fn = 96;

// Parameters
rod_diameter = 8.0; //[4.0:16.0:0.1]
rod_length = 60.0; //[30.0:200.0:1]
overall_height = 20.0; //[10.0:40.0:0.5]
bracket_width = 30.0; //[15.0:60.0:0.5]
bracket_depth = 20.0; //[10.0:50.0:0.5]
base_thickness = 5.0; //[2.5:12.0:0.5]
wall_thickness = 4.0; //[2.0:10.0:0.5]
rod_clearance = 0.2; //[0.0:0.6:0.05]
mount_hole_diameter = 4.0; //[2.0:8.0:0.1]
mount_hole_spacing = 20.0; //[10.0:40.0:0.5]
rod_center_height_from_base = 12.0; //[7.0:25.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
retention_slit_width = 2.0; //[1.0:4.0:0.5]

// Derived
rod_r = rod_diameter/2;
bore_r = (rod_diameter + rod_clearance)/2;

// Clamp block sizing (SK8-like)
clamp_block_h = overall_height - base_thickness;
clamp_block_w = bracket_width;
clamp_block_d = max(bracket_depth, rod_diameter + 2*wall_thickness + 6); // ensure enough meat around bore

// Ensure the bore is inside the clamp block
rod_center_z = min(
    base_thickness + clamp_block_h - (bore_r + wall_thickness),
    max(base_thickness + (bore_r + wall_thickness), rod_center_height_from_base)
);

// Clamp split: from top down to just above bore center (typical SK8 split)
split_top_z = base_thickness + clamp_block_h;
split_bottom_z = rod_center_z + bore_r*0.15; // leave a small bridge below split
split_h = max(0.1, split_top_z - split_bottom_z);

// Mount hole placement (along depth)
mount_y_offset = clamp_block_d*0.25;

// One connected solid: bracket + captive insert ring (no floating parts)
module sk8_bracket() {

    // Insert/ring thickness around bore (orange part in screenshots)
    insert_radial = 1.5;                 // 1–2mm overlap/attachment margin radially
    insert_r_outer = bore_r + insert_radial;
    insert_len = clamp_block_d + 2*overlap; // ensure it intersects the clamp block through depth

    // Ensure the clamp split does NOT fully separate the bracket halves:
    // leave a small bridge on each side of the slit.
    // (If retention_slit_width is too large, clamp it to keep at least 1mm per side.)
    min_side_bridge = 1.0;
    effective_slit_w = min(retention_slit_width, max(0.1, clamp_block_w - 2*min_side_bridge));

    difference() {
        union() {
            // Base plate
            translate([0, 0, base_thickness/2])
                cube([bracket_width, clamp_block_d, base_thickness], center=true);

            // Clamp block sitting on base (overlap to ensure connectivity)
            translate([0, 0, base_thickness + clamp_block_h/2 - overlap])
                cube([clamp_block_w, clamp_block_d, clamp_block_h], center=true);

            // Small front/back gussets (connected by overlap)
            gus_w = clamp_block_w*0.55;
            gus_d = clamp_block_d*0.18;
            gus_h = clamp_block_h*0.55;

            for (sy = [-1, 1]) {
                translate([0,
                           sy*(clamp_block_d/2 - gus_d/2),
                           base_thickness + gus_h/2 - overlap])
                    hull() {
                        cube([gus_w, gus_d, gus_h], center=true);
                        translate([0, -sy*(gus_d*0.6), -gus_h*0.35])
                            cube([gus_w*0.75, gus_d*0.6, gus_h*0.3], center=true);
                    }
            }

            // Captive cylindrical insert/ring around the bore:
            // This is physically attached because it overlaps the clamp block volume.
            // (It is NOT subtracted by the bore because we add it in union and only
            // subtract the inner bore cylinder below.)
            translate([0, 0, rod_center_z])
                rotate([90, 0, 0])
                    difference() {
                        cylinder(r=insert_r_outer, h=insert_len, center=true);
                        cylinder(r=bore_r,        h=insert_len + 2*overlap, center=true);
                    }
        }

        // Rod bore (through depth) - subtract only the inner bore
        translate([0, 0, rod_center_z])
            rotate([90, 0, 0])
                cylinder(r=bore_r, h=clamp_block_d + 4*overlap, center=true);

        // Clamp split (slot) from top down - keep halves connected by limiting slit width
        translate([0, 0, split_bottom_z + split_h/2])
            cube([effective_slit_w, clamp_block_d + 2*overlap, split_h + 2*overlap], center=true);

        // Mounting holes through base
        for (sx = [-1, 1]) {
            translate([sx*mount_hole_spacing/2, -mount_y_offset, base_thickness/2])
                cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
            translate([sx*mount_hole_spacing/2,  mount_y_offset, base_thickness/2])
                cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
        }

        // Counterbore-ish relief on top of base around holes
        cb_r = mount_hole_diameter/2 + 2.0;
        cb_h = min(2.0, base_thickness*0.6);
        for (sx = [-1, 1]) {
            translate([sx*mount_hole_spacing/2, -mount_y_offset, base_thickness - cb_h/2])
                cylinder(r=cb_r, h=cb_h + 2*overlap, center=true);
            translate([sx*mount_hole_spacing/2,  mount_y_offset, base_thickness - cb_h/2])
                cylinder(r=cb_r, h=cb_h + 2*overlap, center=true);
        }
    }
}

sk8_bracket();
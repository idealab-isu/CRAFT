// Linear bearing block for 6.0mm shaft
// Block size: 30.0mm x 25.0mm x 18.0mm
// One connected solid (single printable part) with through-bore + mounting holes + retention slit + clamp screw

$fn = 96;

// Parameters
shaft_diameter_mm = 6;                 //[3:12:0.1]
block_length_mm   = 30;                //[15:60:1]   // X
block_width_mm    = 25;                //[12.5:50:1] // Y
block_height_mm   = 18;                //[9:36:1]    // Z

bore_diameter_mm  = 6;                 //[3:12:0.1]
bore_clearance_mm = 0.2;               //[0:1:0.05]
bore_center_height_mm = 9;             //[6:16:0.5]  // from bottom face (typical: centered)

mounting_hole_diameter_mm = 4.2;       //[2:8:0.1]
mounting_hole_spacing_x_mm = 20;       //[10:40:1]
mounting_hole_spacing_y_mm = 16;       //[8:32:1]

retention_slit_width_mm = 1.5;         //[0.8:3:0.1]
retention_slit_overcut_mm = 1;         //[0.5:2:0.1]
retention_screw_diameter_mm = 3.2;     //[2:6:0.1]
retention_screw_head_diameter_mm = 6.2;//[4:10:0.1]
retention_screw_head_depth_mm = 3;     //[1.5:6:0.1]
retention_screw_z_offset_mm = 3;       //[1:8:0.5]   // above bore center

// Use 1-2mm overlap to guarantee watertight connections
overlap_mm = 1.2;                      //[0.2:2:0.1]

module linear_bearing_block() {
    // Derived
    bore_r = (bore_diameter_mm + bore_clearance_mm)/2;

    // Convert bottom-based bore height to centered coordinates
    bore_z = -block_height_mm/2 + bore_center_height_mm;

    // Clamp bore center so the bore stays fully inside the block
    bore_z_clamped =
        min(
            max(bore_z, -block_height_mm/2 + bore_r + 0.8),
            block_height_mm/2 - bore_r - 0.8
        );

    // Mounting holes (4x) through Z
    hx = mounting_hole_spacing_x_mm/2;
    hy = mounting_hole_spacing_y_mm/2;

    // Keep mounting holes inside the block footprint
    edge_margin_x = 2.0 + mounting_hole_diameter_mm/2;
    edge_margin_y = 2.0 + mounting_hole_diameter_mm/2;
    hx_clamped = min(hx, block_length_mm/2 - edge_margin_x);
    hy_clamped = min(hy, block_width_mm/2  - edge_margin_y);

    // Retention slit: from top down to just below bore center
    slit_top_z = block_height_mm/2 + overlap_mm;
    slit_bottom_z = (bore_z_clamped - bore_r - retention_slit_overcut_mm);

    // Ensure slit has positive height and stays within block
    slit_bottom_z_clamped = max(slit_bottom_z, -block_height_mm/2 - overlap_mm);
    slit_mid_z = (slit_top_z + slit_bottom_z_clamped)/2;
    slit_h = (slit_top_z - slit_bottom_z_clamped);

    // Clamp screw: along Y, crosses slit above bore
    screw_z = bore_z_clamped + retention_screw_z_offset_mm;
    screw_z_clamped =
        min(
            max(screw_z, -block_height_mm/2 + 2.0),
            block_height_mm/2 - 2.0
        );

    // --- STRUCTURAL CONNECTIVITY FIX ---
    // The retention slit can split the body into two disconnected halves.
    // Add a "stitch" rib that crosses the slit in Y and is placed BELOW the slit cut,
    // so it is not removed by the slit subtraction. It overlaps the main body by 1-2mm.
    stitch_thickness_z = 2.0; // 2mm tall rib
    stitch_y = retention_slit_width_mm + 2*overlap_mm; // spans across slit with overlap into both sides
    stitch_x = block_length_mm + 2*overlap_mm;         // full length with overlap

    // Place rib just below the slit bottom (so it survives the slit subtraction)
    stitch_z_top_target = slit_bottom_z_clamped - overlap_mm;
    stitch_z_center = stitch_z_top_target - stitch_thickness_z/2;

    // Clamp rib inside the block
    stitch_z_center_clamped =
        min(
            max(stitch_z_center, -block_height_mm/2 + stitch_thickness_z/2),
            block_height_mm/2 - stitch_thickness_z/2
        );

    union() {
        // Solid body with all cutouts
        difference() {
            // Main body
            cube([block_length_mm, block_width_mm, block_height_mm], center=true);

            // Through bore for 6mm shaft (along X) - true through-hole
            translate([0, 0, bore_z_clamped])
                rotate([0, 90, 0])
                    cylinder(h=block_length_mm + 2*overlap_mm, r=bore_r, center=true);

            // Mounting holes (4x) through Z
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*hx_clamped, sy*hy_clamped, 0])
                    cylinder(h=block_height_mm + 2*overlap_mm,
                             r=mounting_hole_diameter_mm/2,
                             center=true);

            // Retention slit (opens from top, intersects bore region)
            translate([0, 0, slit_mid_z])
                cube([block_length_mm + 2*overlap_mm,
                      retention_slit_width_mm,
                      slit_h + 2*overlap_mm],
                     center=true);

            // Clamp screw clearance (through Y) + counterbore for head on +Y side
            translate([0, 0, screw_z_clamped]) {
                rotate([90, 0, 0])
                    cylinder(h=block_width_mm + 2*overlap_mm,
                             r=retention_screw_diameter_mm/2,
                             center=true);

                // Counterbore on +Y face (kept intersecting the body with overlap)
                translate([0,
                           block_width_mm/2 - retention_screw_head_depth_mm/2 + overlap_mm/2,
                           0])
                    rotate([90, 0, 0])
                        cylinder(h=retention_screw_head_depth_mm + overlap_mm,
                                 r=retention_screw_head_diameter_mm/2,
                                 center=true);
            }
        }

        // Stitch rib: guarantees the "upper/lower halves" are physically merged (no floating parts)
        translate([0, 0, stitch_z_center_clamped])
            cube([stitch_x, stitch_y, stitch_thickness_z], center=true);
    }
}

linear_bearing_block();
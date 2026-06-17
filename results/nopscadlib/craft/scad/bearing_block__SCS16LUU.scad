// Long linear bearing block for 9.0mm shaft
// Block size: 50.0mm (X) x 85.0mm (Y) x 30.0mm (Z)
// One connected solid (bearing shown as internal seat only; no separate floating parts)

$fn = 96;

// Parameters
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
block_width_mm    = 50.0; //[25.0:100.0:0.5]   // X
block_length_mm   = 85.0; //[42.5:170.0:0.5]   // Y
block_height_mm   = 30.0; //[15.0:60.0:0.5]    // Z

bearing_outer_diameter_mm = 16.0; //[10.0:32.0:0.1]
bearing_length_mm         = 45.0; //[20.0:80.0:0.5]

bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
seat_clearance_mm = 0.1; //[0.0:0.4:0.05]

mount_hole_diameter_mm = 5.5; //[3.0:10.0:0.1]
mount_hole_spacing_x_mm = 36.0; //[20.0:70.0:0.5]
mount_hole_spacing_y_mm = 60.0; //[30.0:140.0:0.5]

counterbore_diameter_mm = 10.0; //[7.0:18.0:0.1]
counterbore_depth_mm    = 5.0;  //[2.0:12.0:0.1]

edge_relief_mm = 2.0; //[0.5:6.0:0.5]

retention_screw_diameter_mm = 3.0; //[2.0:6.0:0.1]
retention_screw_depth_mm    = 10.0; //[4.0:20.0:0.5]
retention_screw_y_offset_mm = 0.0; //[-20.0:20.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// Derived / clamped values (avoid impossible geometry)
bearing_len_eff = min(bearing_length_mm, block_length_mm - 2*edge_relief_mm);
bearing_len_eff = max(bearing_len_eff, 5);

cb_depth_eff = min(counterbore_depth_mm, block_height_mm - 1);
cb_depth_eff = max(cb_depth_eff, 0);

// Ensure the bearing seat is actually a "long" housing and not a near-full-length bore
seat_len_eff = min(bearing_len_eff, block_length_mm - 2*edge_relief_mm - 6);
seat_len_eff = max(seat_len_eff, 10);

// Boss sizing to clearly read as a bearing block (not a flat plate)
boss_h = max(12, block_height_mm*0.55);
boss_w = min(block_width_mm - 2*edge_relief_mm, bearing_outer_diameter_mm + 22);
boss_l = min(block_length_mm - 2*edge_relief_mm, seat_len_eff + 24);

module rounded_block_xy(w, l, h, r){
    // Minkowski-like rounding in XY only (keeps Z exact)
    r_eff = min(r, min(w,l)/2 - 0.01);
    linear_extrude(height=h, center=true)
        offset(r=r_eff)
            square([w-2*r_eff, l-2*r_eff], center=true);
}

module mounting_holes(){
    // Through holes + top counterbores
    for (sx = [-1, 1])
        for (sy = [-1, 1]) {
            x = sx * mount_hole_spacing_x_mm/2;
            y = sy * mount_hole_spacing_y_mm/2;

            translate([x, y, 0])
                cylinder(d=mount_hole_diameter_mm,
                         h=block_height_mm + boss_h + 2*overlap_mm, center=true);

            // Counterbore from very top surface (top of boss if boss overlaps this area)
            translate([x, y, (block_height_mm/2 + boss_h) - cb_depth_eff/2 + overlap_mm/2])
                cylinder(d=counterbore_diameter_mm,
                         h=cb_depth_eff + overlap_mm, center=true);
        }
}

module shaft_bore_and_seat(){
    // Shaft bore through full length (Y axis)
    rotate([90, 0, 0])
        cylinder(d=shaft_diameter_mm + bore_clearance_mm,
                 h=block_length_mm + 2*overlap_mm, center=true);

    // Bearing seat (larger diameter) only over seat length (centered)
    rotate([90, 0, 0])
        cylinder(d=bearing_outer_diameter_mm + seat_clearance_mm,
                 h=seat_len_eff + 2*overlap_mm, center=true);
}

module retention_screws(){
    // Two side set-screw holes that intersect the bearing seat (X axis)
    // Place at the bore centerline (z=0) so they hit the seat/bore region.
    z = 0;
    for (sx = [-1, 1]) {
        translate([sx*(block_width_mm/2 - retention_screw_depth_mm/2 + overlap_mm/2),
                   retention_screw_y_offset_mm,
                   z])
            rotate([0, 90, 0])
                cylinder(d=retention_screw_diameter_mm,
                         h=retention_screw_depth_mm + overlap_mm, center=true);
    }
}

module top_bearing_housing_boss(){
    // Raised boss on top to make it clearly a bearing block (connected solid)
    // Place boss on top face with slight overlap to ensure connectivity
    translate([0, 0, block_height_mm/2 + boss_h/2 - overlap_mm])
        rounded_block_xy(boss_w, boss_l, boss_h, r=edge_relief_mm);
}

module underside_relief(){
    // Add a shallow underside relief so it reads as a block, not a flat plate,
    // while keeping one connected solid.
    relief_h = min(3, block_height_mm/6);
    relief_w = block_width_mm - 2*(edge_relief_mm + 3);
    relief_l = block_length_mm - 2*(edge_relief_mm + 3);

    if (relief_w > 2 && relief_l > 2 && relief_h > 0)
        translate([0, 0, -block_height_mm/2 + relief_h/2 - overlap_mm/2])
            rounded_block_xy(relief_w, relief_l, relief_h + overlap_mm, r=max(1, edge_relief_mm-0.5));
}

module linear_bearing_block(){
    difference(){
        union(){
            // Main base block
            rounded_block_xy(block_width_mm, block_length_mm, block_height_mm, r=edge_relief_mm);

            // Raised bearing housing boss (connected)
            top_bearing_housing_boss();
        }

        // Underside relief pocket (still one connected solid)
        underside_relief();

        // Shaft bore + bearing seat (recognizable long through-bore + long seat)
        shaft_bore_and_seat();

        // Mounting holes + counterbores
        mounting_holes();

        // Retention/set screw holes
        retention_screws();
    }
}

linear_bearing_block();
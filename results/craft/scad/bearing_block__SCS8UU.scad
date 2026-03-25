// Parameters
shaft_diameter_mm = 6.0; //[3.0:12.0:0.1]
block_length_mm = 34.0; //[17.0:68.0:0.5]
block_width_mm = 30.0; //[15.0:60.0:0.5]
block_height_mm = 20.0; //[10.0:40.0:0.5]
bearing_outer_diameter_mm = 12.0; //[8.0:24.0:0.1]
bearing_length_mm = 19.0; //[10.0:38.0:0.1]
bore_diameter_mm = 6.0; //[3.0:12.0:0.1]
bore_clearance_mm = 0.2; //[0.0:0.6:0.05]
mounting_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mounting_hole_spacing_x_mm = 24.0; //[12.0:48.0:0.5]
mounting_hole_spacing_y_mm = 20.0; //[10.0:40.0:0.5]
clamp_slot_width_mm = 2.0; //[1.0:4.0:0.1]
clamp_slot_depth_mm = 12.0; //[6.0:18.0:0.5]
clamp_screw_clearance_diameter_mm = 3.4; //[2.4:6.0:0.1]
clamp_boss_diameter_mm = 10.0; //[6.0:18.0:0.5]
clamp_boss_height_mm = 6.0; //[3.0:12.0:0.5]
bearing_seat_clearance_mm = 0.2; //[0.0:0.6:0.05]
bearing_seat_depth_mm = 16.0; //[8.0:30.0:0.5]
edge_margin_mm = 4.0; //[2.0:8.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// --- Added: corner fastener/bolt heads (fused to body with overlap) ---
bolt_head_d_mm = 8.0;          // visual head diameter
bolt_head_h_mm = 3.0;          // visual head height
bolt_head_overlap_mm = 1.2;    // 1-2mm overlap into the block to guarantee fusion
bolt_head_fn = 6;              // hex-like

module corner_bolt_heads() {
  // Place heads centered over the mounting hole pattern.
  // Ensure they intersect the top face by (bolt_head_overlap_mm).
  zc = block_height_mm/2 + bolt_head_h_mm/2 - bolt_head_overlap_mm;

  for (x = [-mounting_hole_spacing_x_mm/2, mounting_hole_spacing_x_mm/2])
    for (y = [-mounting_hole_spacing_y_mm/2, mounting_hole_spacing_y_mm/2])
      translate([x, y, zc])
        cylinder(d=bolt_head_d_mm, h=bolt_head_h_mm, center=true, $fn=bolt_head_fn);
}

// SCS8UU Bearing Block (body only)
module scs_bearing_block_body() {
  difference() {
    // Main block
    cube([block_length_mm, block_width_mm, block_height_mm], center=true);

    // Shaft bore
    cylinder(r=(bore_diameter_mm + bore_clearance_mm)/2,
             h=block_height_mm + 2*overlap_mm, center=true);

    // Bearing seat
    translate([0, 0, block_height_mm/2 - (bearing_seat_depth_mm + overlap_mm)/2])
      cylinder(r=(bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2,
               h=bearing_seat_depth_mm + overlap_mm, center=true);

    // Mounting holes
    for (x = [-mounting_hole_spacing_x_mm/2, mounting_hole_spacing_x_mm/2])
      for (y = [-mounting_hole_spacing_y_mm/2, mounting_hole_spacing_y_mm/2])
        translate([x, y, 0])
          cylinder(r=mounting_hole_diameter_mm/2,
                   h=block_height_mm + 2*overlap_mm, center=true);

    // Split clamp slot
    translate([0, 0, block_height_mm/2 - (clamp_slot_depth_mm + overlap_mm)/2])
      cube([clamp_slot_width_mm, block_width_mm + 2*overlap_mm,
            clamp_slot_depth_mm + overlap_mm], center=true);
  }
}

// Linear Bearing (kept as-is; assembly unions it with the block)
module linear_bearing() {
  color([0.0, 0.4, 0.2]) {
    translate([0, 0, block_height_mm/2 - bearing_seat_depth_mm/2])
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_length_mm, center=true);
  }
}

// SCS Bearing Block (body + fused bolt heads)
module scs_bearing_block() {
  color([0.85, 0.85, 0.8]) {
    union() {
      scs_bearing_block_body();
      corner_bolt_heads(); // FIX: physically attached via overlap into top face
    }
  }
}

// SBR Bearing Block (kept, but also gets fused bolt heads for structural integrity if used)
module sbr_bearing_block() {
  color([0.85, 0.85, 0.8]) {
    union() {
      difference() {
        // Main block
        cube([block_length_mm, block_width_mm, block_height_mm], center=true);

        // Shaft bore
        cylinder(r=(bore_diameter_mm + bore_clearance_mm)/2,
                 h=block_height_mm + 2*overlap_mm, center=true);

        // Bearing seat
        translate([0, 0, block_height_mm/2 - (bearing_seat_depth_mm + overlap_mm)/2])
          cylinder(r=(bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2,
                   h=bearing_seat_depth_mm + overlap_mm, center=true);

        // Mounting holes
        for (x = [-mounting_hole_spacing_x_mm/2, mounting_hole_spacing_x_mm/2])
          for (y = [-mounting_hole_spacing_y_mm/2, mounting_hole_spacing_y_mm/2])
            translate([x, y, 0])
              cylinder(r=mounting_hole_diameter_mm/2,
                       h=block_height_mm + 2*overlap_mm, center=true);

        // Split clamp slot
        translate([0, 0, block_height_mm/2 - (clamp_slot_depth_mm + overlap_mm)/2])
          cube([clamp_slot_width_mm, block_width_mm + 2*overlap_mm,
                clamp_slot_depth_mm + overlap_mm], center=true);
      }
      corner_bolt_heads(); // FIX: ensure no floating fasteners if this block is used
    }
  }
}

// SCS Bearing Block Assembly (single connected solid)
module scs_bearing_block_assembly() {
  union() {
    scs_bearing_block();
    linear_bearing();
  }
}

// SCS Bearing Block Hole Positions (visual aid)
module scs_bearing_block_hole_positions() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -block_height_mm/2 + overlap_mm/2])
      cube([mounting_hole_spacing_x_mm, mounting_hole_spacing_y_mm, overlap_mm], center=true);
  }
}

// SBR Bearing Block Hole Positions (visual aid)
module sbr_bearing_block_hole_positions() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -block_height_mm/2 + overlap_mm/2])
      cube([mounting_hole_spacing_x_mm, mounting_hole_spacing_y_mm, overlap_mm], center=true);
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
  scs_bearing_block_hole_positions();
  sbr_bearing_block_hole_positions();
}

assembly();
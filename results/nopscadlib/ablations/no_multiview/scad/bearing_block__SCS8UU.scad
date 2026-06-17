// Parameters
shaft_diameter = 6.0; //[3.0:12.0:0.1]
block_length = 34.0; //[17.0:68.0:0.5]
block_width = 30.0; //[15.0:60.0:0.5]
block_height = 20.0; //[10.0:40.0:0.5]
shaft_bore_clearance = 0.2; //[0.0:0.6:0.05]
bearing_outer_diameter = 12.0; //[6.0:24.0:0.1]
bearing_length = 19.0; //[10.0:38.0:0.5]
bearing_fit_clearance = 0.1; //[0.0:0.4:0.05]
mount_hole_diameter = 4.2; //[2.0:8.0:0.1]
mount_hole_edge_margin = 5.0; //[2.5:10.0:0.5]
mount_hole_spacing_x = 24.0; //[12.0:48.0:0.5]
mount_hole_spacing_y = 20.0; //[10.0:40.0:0.5]
split_slot_width = 1.5; //[0.8:3.0:0.1]
clamp_screw_diameter = 3.0; //[2.0:6.0:0.1]
clamp_screw_clearance = 3.2; //[2.2:6.5:0.1]
mount_counterbore_diameter = 8.0; //[5.0:14.0:0.5]
mount_counterbore_depth = 3.0; //[1.0:8.0:0.5]
clamp_boss_diameter = 8.0; //[5.0:16.0:0.5]
clamp_boss_length = 6.0; //[3.0:12.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// --- Helpers (positive geometry) ---
module main_body_solid() {
  cube([block_length, block_width, block_height], center=true);
}

// Two circular "insert/bearing" pads on the bottom face (ATTACHED, with overlap)
module bottom_pads_solid() {
  // Place along X, centered in Y, attached to bottom (Z-)
  pad_d = mount_counterbore_diameter;          // match the visible circular features
  pad_h = mount_counterbore_depth;             // thickness similar to counterbore depth
  pad_spacing_x = mount_hole_spacing_x;        // align with mounting pattern

  // Ensure physical connection: top of pad penetrates into block by `overlap`
  // Block bottom is at z = -block_height/2
  // Pad center z so that pad top is at (-block_height/2 + overlap)
  pad_center_z = -block_height/2 - pad_h/2 + overlap;

  for (x = [-1, 1]) {
    translate([x * pad_spacing_x/2, 0, pad_center_z])
      cylinder(h=pad_h, r=pad_d/2, center=true, $fn=64);
  }
}

// --- Cutters (negative geometry) ---
module shaft_and_bearing_cuts() {
  // Shaft bore (through X)
  rotate([0, 90, 0])
    cylinder(h=block_length + 2*overlap, r=(shaft_diameter + shaft_bore_clearance)/2, center=true, $fn=96);

  // Bearing seat counterbore (through X, shorter)
  rotate([0, 90, 0])
    cylinder(h=bearing_length + 2*overlap, r=(bearing_outer_diameter + bearing_fit_clearance)/2, center=true, $fn=96);

  // Split clamp slot (through X, full height)
  cube([block_length + 2*overlap, split_slot_width, block_height + 2*overlap], center=true);
}

module mounting_hole_cuts() {
  // Through mounting holes
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=64);
  }

  // Counterbores from bottom face
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2,
               -block_height/2 + mount_counterbore_depth/2])
      cylinder(h=mount_counterbore_depth + overlap, r=mount_counterbore_diameter/2, center=true, $fn=64);
  }
}

module clamp_boss_and_screw_cuts() {
  // These were previously SUBTRACTED (creating "floating-looking" circular features).
  // Keep them as cuts, but ensure they are positioned relative to the block face.
  boss_center_y = block_width/2 + clamp_boss_length/2 - overlap;

  // Boss relief cuts
  for (z = [-1, 1]) {
    translate([0, boss_center_y, z * block_height/4])
      rotate([90, 0, 0])
        cylinder(h=clamp_boss_length, r=clamp_boss_diameter/2, center=true, $fn=64);
  }

  // Clamp screw holes (through)
  for (z = [-1, 1]) {
    translate([0, boss_center_y, z * block_height/4])
      rotate([90, 0, 0])
        cylinder(h=block_width + clamp_boss_length + 2*overlap, r=clamp_screw_clearance/2, center=true, $fn=64);
  }
}

// --- Final assembly (single connected solid) ---
module scs_bearing_block_assembly() {
  color([0.85, 0.85, 0.8])
  difference() {
    // UNION all positive solids so nothing is floating/disconnected
    union() {
      main_body_solid();
      bottom_pads_solid();   // attached with 1mm overlap into the main body
    }

    // Subtractions
    shaft_and_bearing_cuts();
    mounting_hole_cuts();
    clamp_boss_and_screw_cuts();
  }
}

// Assembly
scs_bearing_block_assembly();
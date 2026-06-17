// Linear bearing block for 8.0mm shaft
// Block size: 40.0mm (X) x 35.0mm (Y) x 28.0mm (Z)
// One connected solid; no floating parts; all translate() values derived from dimensions.

// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
block_length_mm = 40.0; //[20.0:80.0:0.5]
block_width_mm  = 35.0; //[18.0:70.0:0.5]
block_height_mm = 28.0; //[14.0:56.0:0.5]

bearing_outer_diameter_mm = 15.0; //[10.0:30.0:0.1]
bearing_length_mm = 24.0; //[12.0:48.0:0.5]
bearing_seat_diameter_clearance_mm = 0.1; //[0.0:0.5:0.05]
shaft_bore_clearance_mm = 0.05; //[0.0:0.3:0.05]

mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x_mm = 30.0; //[15.0:60.0:0.5]
mount_hole_spacing_y_mm = 25.0; //[12.0:50.0:0.5]
mount_counterbore_diameter_mm = 9.0; //[6.0:14.0:0.1]
mount_counterbore_depth_mm = 3.0; //[0.0:8.0:0.5]

clamp_slot_width_mm = 2.0; //[1.0:4.0:0.5]
clamp_screw_diameter_mm = 4.0; //[3.0:6.0:0.1]
clamp_screw_head_diameter_mm = 7.5; //[5.0:12.0:0.1]
clamp_screw_head_depth_mm = 3.0; //[1.0:8.0:0.5]
clamp_screw_x_offset_mm = 12.0; //[0.0:18.0:0.5]  // distance from center along X

overlap_mm = 1.0; //[0.5:2.0:0.1]

// Derived
bearing_seat_r = (bearing_outer_diameter_mm + bearing_seat_diameter_clearance_mm)/2;
shaft_bore_r   = (shaft_diameter_mm + shaft_bore_clearance_mm)/2;

// Sanity helpers
function clamp(v, lo, hi) = min(max(v, lo), hi);

// Visualization only (not part of body)
module linear_bearing() {
  color([0.0, 0.4, 0.2])
    rotate([0,90,0])
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_length_mm, center=true, $fn=96);
}

// Mount holes: through + counterbore from top face (Z+)
module mount_holes() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=48);

    translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2,
               block_height_mm/2 - mount_counterbore_depth_mm/2 + overlap_mm/2])
      cylinder(r=mount_counterbore_diameter_mm/2,
               h=mount_counterbore_depth_mm + overlap_mm,
               center=true, $fn=64);
  }
}

// Main bearing block body (ONE connected solid)
module bearing_block_body() {
  // Clamp slot depth: from top face down to just above the bearing seat
  // Keep a small roof thickness so the body remains robust.
  roof_thickness_mm = 2.0;
  slot_depth_mm = clamp(block_height_mm/2 - (bearing_seat_r + roof_thickness_mm), 0, block_height_mm);

  // Slot center Z so its top is at +block_height/2
  slot_center_z = block_height_mm/2 - slot_depth_mm/2;

  // Clamp screw Z: slightly below top face, centered in the clamp region
  clamp_screw_z = block_height_mm/2 - max(roof_thickness_mm, clamp_screw_diameter_mm/2 + 0.5);

  // Clamp screw X positions (two screws, typical clamp geometry)
  clamp_screw_x = clamp(clamp_screw_x_offset_mm, 0, block_length_mm/2 - mount_counterbore_diameter_mm/2 - 1);

  color("DimGray")
  difference() {
    // Solid block
    cube([block_length_mm, block_width_mm, block_height_mm], center=true);

    union() {
      // Bearing seat (cylindrical bore through X)
      rotate([0,90,0])
        cylinder(r=bearing_seat_r, h=block_length_mm + 2*overlap_mm, center=true, $fn=160);

      // Shaft bore (through X) - ensures clear 8mm pass-through
      rotate([0,90,0])
        cylinder(r=shaft_bore_r, h=block_length_mm + 2*overlap_mm, center=true, $fn=160);

      // Clamp slot: cut from top down, along X, narrow in Y
      // This creates the typical split-clamp geometry while keeping one connected solid.
      translate([0, 0, slot_center_z])
        cube([block_length_mm + 2*overlap_mm,
              clamp_slot_width_mm,
              slot_depth_mm + 2*overlap_mm],
             center=true);

      // Clamp screw holes across Y (width), with head counterbore from +Y side
      for (sx = [-1, 1]) {
        // Through hole
        translate([sx*clamp_screw_x, 0, clamp_screw_z])
          rotate([90,0,0])
            cylinder(r=clamp_screw_diameter_mm/2,
                     h=block_width_mm + 2*overlap_mm,
                     center=true, $fn=64);

        // Head counterbore from +Y face
        translate([sx*clamp_screw_x,
                   block_width_mm/2 - clamp_screw_head_depth_mm/2 + overlap_mm/2,
                   clamp_screw_z])
          rotate([90,0,0])
            cylinder(r=clamp_screw_head_diameter_mm/2,
                     h=clamp_screw_head_depth_mm + overlap_mm,
                     center=true, $fn=64);
      }

      // Base mounting holes
      mount_holes();
    }
  }
}

// Assembly (block + optional bearing visualization)
module assembly() {
  bearing_block_body();
  // Visualize bearing inside seat (does not affect block connectivity)
  linear_bearing();
}

assembly();
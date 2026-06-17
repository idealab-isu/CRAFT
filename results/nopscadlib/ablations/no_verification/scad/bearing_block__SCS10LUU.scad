// Long linear bearing block for 8.0mm shaft
// Block size: 40.0mm (X) x 68.0mm (Y) x 28.0mm (Z)
// One connected solid (with holes/slots subtracted)

$fn = 96;

// -------------------- Parameters --------------------
shaft_diameter_mm = 8.0;                 // shaft bore
block_width_mm    = 40.0;                // X
block_length_mm   = 68.0;                // Y
block_height_mm   = 28.0;                // Z

// Long bearing seat (LM8UU-like) inside block (along Y)
bearing_seat_diameter_mm = 15.0;         // OD seat
bearing_seat_length_mm   = 45.0;         // seat length along Y (long block)

// Bore axis height from base (Z-)
bearing_axis_offset_from_base_mm = 16.0; // from bottom face

// Mounting holes (4x) - SCS/SBR-ish pattern on top face
mount_hole_diameter_mm   = 5.0;
mount_hole_spacing_x_mm  = 28.0;
mount_hole_spacing_y_mm  = 50.0;
counterbore_diameter_mm  = 9.0;
counterbore_depth_mm     = 4.0;

// Clamp slot + screw (split clamp across X, screw along X)
clamp_slot_width_mm      = 2.0;          // slit width (gap) along X
clamp_slot_depth_mm      = 12.0;         // how far slit goes down from top
clamp_screw_diameter_mm  = 4.0;
clamp_screw_head_diameter_mm = 7.5;
clamp_screw_head_depth_mm    = 3.0;

// Small overlap for robust booleans
overlap_mm = 0.6;

// Derived
bearing_axis_z = -block_height_mm/2 + bearing_axis_offset_from_base_mm;

// -------------------- Helpers --------------------
module rounded_block(size=[40,68,28], r=2.0) {
  minkowski() {
    cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
    sphere(r=r);
  }
}

module mount_holes() {
  // Through holes + counterbores from top face
  for (sx = [-1, 1])
    for (sy = [-1, 1]) {
      translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0]) {
        cylinder(d=mount_hole_diameter_mm,
                 h=block_height_mm + 2*overlap_mm, center=true);

        translate([0,0, block_height_mm/2 - counterbore_depth_mm/2 + overlap_mm/2])
          cylinder(d=counterbore_diameter_mm,
                   h=counterbore_depth_mm + overlap_mm, center=true);
      }
    }
}

module bearing_bore_and_seat() {
  // Main shaft bore (through Y)
  translate([0, 0, bearing_axis_z])
    rotate([90,0,0])
      cylinder(d=shaft_diameter_mm + 0.4,
               h=block_length_mm + 2*overlap_mm, center=true);

  // Bearing seat pocket (shorter than full length, centered)
  translate([0, 0, bearing_axis_z])
    rotate([90,0,0])
      cylinder(d=bearing_seat_diameter_mm,
               h=bearing_seat_length_mm + 2*overlap_mm, center=true);

  // Lead-in chamfers at both Y ends of shaft bore
  chamfer_d = shaft_diameter_mm + 2.0;
  chamfer_h = 1.2;
  for (sy = [-1, 1]) {
    translate([0, sy*(block_length_mm/2 - chamfer_h/2 + overlap_mm/2), bearing_axis_z])
      rotate([90,0,0])
        cylinder(d1=chamfer_d, d2=shaft_diameter_mm + 0.4,
                 h=chamfer_h + overlap_mm, center=true);
  }
}

module clamp_features() {
  // Slit from top down (split clamp), centered at X=0, runs along Y
  slit_z_center = block_height_mm/2 - clamp_slot_depth_mm/2 + overlap_mm/2;
  translate([0, 0, slit_z_center])
    cube([clamp_slot_width_mm,
          block_length_mm + 2*overlap_mm,
          clamp_slot_depth_mm + overlap_mm],
         center=true);

  // Clamp screw across the slit (along X), placed above bore
  screw_z = bearing_axis_z + (block_height_mm/2 - bearing_axis_z) * 0.55;

  translate([0, 0, screw_z]) {
    rotate([0,90,0]) {
      // through hole along X
      cylinder(d=clamp_screw_diameter_mm,
               h=block_width_mm + 2*overlap_mm, center=true);

      // head pocket from +X side
      translate([0, 0, block_width_mm/2 - clamp_screw_head_depth_mm/2 + overlap_mm/2])
        cylinder(d=clamp_screw_head_diameter_mm,
                 h=clamp_screw_head_depth_mm + overlap_mm, center=true);
    }
  }
}

// -------------------- Model --------------------
difference() {
  // Single connected body
  rounded_block([block_width_mm, block_length_mm, block_height_mm], r=2.0);

  // Subtractions
  bearing_bore_and_seat();
  mount_holes();
  clamp_features();
}
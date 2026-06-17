// Long linear bearing block for 6.0mm shaft
// Block size: 34.0mm (X) x 58.0mm (Y) x 24.0mm (Z)
// One connected solid (bearing is not a separate part)

$fn = 96;

// Parameters
block_width_mm  = 34;   //[17:68:1]   // X
block_length_mm = 58;   //[29:116:1]  // Y
block_height_mm = 24;   //[12:48:1]   // Z

shaft_diameter_mm      = 6;          //[3:12:0.1]
shaft_bore_diameter_mm = 6.1;        //[6.02:6.6:0.01]

mount_hole_diameter_mm   = 4.2;      //[2.5:8:0.1]
mount_hole_x_spacing_mm  = 24;       //[12:30:1]
mount_hole_y_spacing_mm  = 44;       //[22:54:1]
counterbore_diameter_mm  = 8;        //[6:14:0.5]
counterbore_depth_mm     = 3;        //[1:8:0.5]

chamfer_mm = 0.5;                    //[0.2:2:0.1]

// Typical clamp/boss geometry (kept parametric but derived from block size)
boss_extra_x_mm = 10;                // adds material around bore (X direction)
boss_height_mm  = block_height_mm*0.55;
boss_len_mm     = block_length_mm*0.78;

// IMPORTANT: keep the clamp split as a CUT (gap), but do NOT split the body into two solids.
split_gap_mm    = 1.2;               // clamp split width
split_depth_mm  = block_height_mm*0.85;

clamp_screw_d_mm = 3.2;              // M3 clearance
clamp_screw_head_d_mm = 6.2;         // socket head clearance
clamp_screw_head_h_mm = 3.0;

// Use a real overlap to guarantee manifold unions (1-2mm as requested)
overlap_mm = 1.2;

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
  minkowski() {
    cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

module mount_holes() {
  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx*mount_hole_x_spacing_mm/2, sy*mount_hole_y_spacing_mm/2, 0])
        cylinder(d=mount_hole_diameter_mm,
                 h=block_height_mm + 2*(chamfer_mm+1),
                 center=true);
}

module counterbores() {
  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx*mount_hole_x_spacing_mm/2,
                 sy*mount_hole_y_spacing_mm/2,
                 block_height_mm/2 - counterbore_depth_mm/2 + overlap_mm])
        cylinder(d=counterbore_diameter_mm,
                 h=counterbore_depth_mm + 2*overlap_mm,
                 center=true);
}

module shaft_bore() {
  // Bore along Y (length direction)
  rotate([90,0,0])
    cylinder(d=shaft_bore_diameter_mm,
             h=block_length_mm + 2*(chamfer_mm+1),
             center=true);
}

module clamp_split() {
  // Split from top down to near bore (along Y, thin slot in X)
  translate([0, 0, block_height_mm/2 - split_depth_mm/2 + overlap_mm])
    cube([split_gap_mm,
          block_length_mm + 2*(chamfer_mm+1),
          split_depth_mm + 2*overlap_mm],
         center=true);
}

module clamp_screws() {
  // Two clamp screws across X, placed along Y
  screw_y = block_length_mm*0.22;
  for (sy = [-1, 1]) {
    translate([0, sy*screw_y, block_height_mm/2 - boss_height_mm*0.55])
      rotate([0,90,0]) {
        // through hole
        cylinder(d=clamp_screw_d_mm,
                 h=block_width_mm + boss_extra_x_mm + 2*(chamfer_mm+1),
                 center=true);
        // head recess on +X side
        translate([(block_width_mm + boss_extra_x_mm)/2 - clamp_screw_head_h_mm/2 + overlap_mm, 0, 0])
          cylinder(d=clamp_screw_head_d_mm,
                   h=clamp_screw_head_h_mm + 2*overlap_mm,
                   center=true);
      }
  }
}

module bearing_block() {

  // Derived dims for attachments (kept same intent, but ensure real overlap)
  ear_w = 4;
  ear_l = block_length_mm*0.35;
  ear_h = block_height_mm*0.45;

  // Build ONE connected solid (union), then subtract bores/holes/split.
  difference() {
    union() {

      // Base block with slight edge rounding
      rounded_box([block_width_mm, block_length_mm, block_height_mm], r=1.0, center=true);

      // Top boss (connected) - overlap into base by overlap_mm
      translate([0, 0, block_height_mm/2 - boss_height_mm/2 + overlap_mm])
        rounded_box([block_width_mm + boss_extra_x_mm, boss_len_mm, boss_height_mm], r=1.0, center=true);

      // Side ears (connected) - FIX: ensure they intersect the base (not just touch)
      // Place ear centers so they intrude into the base by overlap_mm.
      ear_center_x = (block_width_mm/2) - (ear_w/2) + overlap_mm; // pushes ear into base
      ear_center_z = (-block_height_mm/2) + (ear_h/2) + overlap_mm; // pushes ear into base
      for (sx = [-1, 1])
        translate([sx*ear_center_x, 0, ear_center_z])
          rounded_box([ear_w + 2*overlap_mm, ear_l, ear_h], r=0.8, center=true);

      // STRUCTURAL FIX 1 (vertical center gap / split halves):
      // Add a hidden internal web across X=0 that is BELOW the clamp split cut.
      // This guarantees left/right halves are physically connected.
      split_bottom_z = block_height_mm/2 - split_depth_mm; // bottom of split cut region
      web_top_z      = split_bottom_z - overlap_mm;        // keep safely below cut
      web_z          = max(2.0, min(block_height_mm*0.35, web_top_z - (-block_height_mm/2) - overlap_mm));
      web_center_z   = (-block_height_mm/2) + web_z/2 + overlap_mm;

      web_x = max(2.0, split_gap_mm + 2*overlap_mm); // spans across the split plane
      web_y = boss_len_mm * 0.92;                    // stays within boss footprint

      translate([0, 0, web_center_z])
        cube([web_x, web_y, web_z], center=true);

      // STRUCTURAL FIX 2 (horizontal separation line mid-height):
      // Add a thin internal "stitch" plate at mid-height that overlaps upper/lower portions.
      // This prevents any accidental Z-splitting from rounding/boolean artifacts.
      stitch_z = 2.0; // 2mm thick
      translate([0, 0, 0])
        cube([block_width_mm - 2.0, block_length_mm - 2.0, stitch_z], center=true);
    }

    // Shaft bore
    shaft_bore();

    // Mounting holes + counterbores (top)
    mount_holes();
    counterbores();

    // Clamp split and clamp screws
    clamp_split();
    clamp_screws();
  }
}

bearing_block();
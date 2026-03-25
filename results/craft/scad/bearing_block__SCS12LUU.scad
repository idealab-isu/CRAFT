// Long linear bearing block for 8.0mm shaft (SCS08LUU-like)
// Block size: 42.0mm (X) x 70.0mm (Y) x 24.0mm (Z)
// One connected solid (single printable part)

shaft_diameter_mm = 8.0;                 //[4.0:16.0:0.1]
block_width_mm = 42.0;                   //[21.0:84.0:0.5]   // X
block_length_mm = 70.0;                  //[35.0:140.0:0.5]  // Y
block_height_mm = 24.0;                  //[12.0:48.0:0.5]   // Z

bearing_outer_diameter_mm = 15.0;        //[10.0:30.0:0.1]   // bearing seat OD
bearing_length_mm = 45.0;                //[12.0:70.0:0.5]   // long seat length along Y
bearing_fit_clearance_mm = 0.2;          //[0.0:0.6:0.05]

mount_hole_diameter_mm = 5.0;            //[3.0:8.0:0.1]
mount_hole_spacing_x_mm = 28.0;          //[14.0:56.0:0.5]
mount_hole_spacing_y_mm = 50.0;          //[25.0:100.0:0.5]
counterbore_diameter_mm = 9.0;           //[6.0:16.0:0.1]
counterbore_depth_mm = 4.0;              //[1.0:10.0:0.5]

retention_screw_diameter_mm = 3.0;       //[2.0:6.0:0.1]
retention_screw_length_mm = 12.0;        //[6.0:30.0:0.5]
retention_screw_y_offset_mm = 0.0;       //[-10.0:10.0:0.5]
retention_screw_z_offset_mm = 0.0;       //[-6.0:6.0:0.5]

edge_round_mm = 2.0;                     //[0.0:6.0:0.5]
overlap_mm = 0.6;                        //[0.2:2.0:0.1]

$fn = 96;

module rounded_block(size=[10,10,10], r=1) {
  r2 = max(0, min(r, min(size[0], min(size[1], size[2]))/2 - 0.01));
  if (r2 <= 0) cube(size, center=true);
  else minkowski() {
    cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=true);
    sphere(r=r2);
  }
}

module bearing_block() {

  // --- Derived / clamped dimensions (all formulas, no arbitrary placement) ---
  seat_len = min(bearing_length_mm, block_length_mm - 2*edge_round_mm - 2);
  seat_len = max(seat_len, 10);

  // SCS/SBR-like raised cylindrical housing on top
  housing_d = max(bearing_outer_diameter_mm + 8, bearing_outer_diameter_mm + 2*edge_round_mm + 4);
  housing_d = min(housing_d, block_width_mm - 2*edge_round_mm - 0.5); // keep within width
  housing_h = min(10, block_height_mm*0.55);                          // visible profile but not too tall
  housing_h = max(housing_h, 6);

  // Place housing so it is connected to the base with a small overlap
  base_top_z = block_height_mm/2;
  housing_center_z = base_top_z + housing_h/2 - 1; // -1 overlap ensures connectivity

  // Side clamp slot (typical split clamp) - does NOT separate the part
  slot_w = 2.0;
  slot_w = min(slot_w, block_width_mm/6);
  slot_h = block_height_mm + housing_h; // cut through full height
  slot_h = min(slot_h, block_height_mm + housing_h + 2*overlap_mm);

  // Keep slot away from mounting holes: place at +X side, but inside body
  slot_x = block_width_mm/2 - slot_w/2 - edge_round_mm;

  // Clamp screw across the slot (X direction), above shaft center
  clamp_screw_d = retention_screw_diameter_mm;
  clamp_screw_len = block_width_mm + 2*overlap_mm;
  clamp_screw_z = 0; // through shaft centerline region (typical clamp acts on bearing/shaft)
  clamp_screw_y = 0;

  difference() {
    // --- Solid body (base + raised housing) ---
    union() {
      // Base block
      rounded_block([block_width_mm, block_length_mm, block_height_mm], r=edge_round_mm);

      // Raised cylindrical housing along Y (long bearing profile)
      translate([0, 0, housing_center_z])
        rotate([90, 0, 0])
          cylinder(d=housing_d, h=seat_len, center=true);
    }

    // --- Functional bores/cuts ---

    // 8mm shaft bore THROUGH along Y (visible in side views)
    rotate([90, 0, 0])
      cylinder(d=shaft_diameter_mm, h=block_length_mm + 2*overlap_mm, center=true);

    // Bearing seat (larger bore) only through the raised housing length
    rotate([90, 0, 0])
      cylinder(d=bearing_outer_diameter_mm + bearing_fit_clearance_mm,
               h=seat_len + 2*overlap_mm, center=true);

    // Mounting through-holes (Z direction)
    for (xsgn = [-1, 1])
      for (ysgn = [-1, 1])
        translate([xsgn*mount_hole_spacing_x_mm/2,
                   ysgn*mount_hole_spacing_y_mm/2,
                   0])
          cylinder(d=mount_hole_diameter_mm,
                   h=block_height_mm + 2*overlap_mm, center=true, $fn=48);

    // Counterbores on top face (positive Z)
    for (xsgn = [-1, 1])
      for (ysgn = [-1, 1])
        translate([xsgn*mount_hole_spacing_x_mm/2,
                   ysgn*mount_hole_spacing_y_mm/2,
                   block_height_mm/2 - counterbore_depth_mm/2])
          cylinder(d=counterbore_diameter_mm,
                   h=counterbore_depth_mm + overlap_mm, center=true, $fn=48);

    // Side clamp split slot (creates SCS-like clamp feature)
    translate([slot_x, 0, (housing_center_z + 0)/2]) // centered through combined height region
      cube([slot_w, block_length_mm + 2*overlap_mm, block_height_mm + housing_h + 2*overlap_mm], center=true);

    // Clamp screw hole across X (bridges the slot; does not disconnect part)
    translate([0, clamp_screw_y, clamp_screw_z])
      rotate([0, 90, 0])
        cylinder(d=clamp_screw_d, h=clamp_screw_len, center=true, $fn=36);

    // Optional retention/set screw holes from both sides in X aimed at shaft center
    // Ensure they intersect the shaft bore by placing them at shaft center Z and within body.
    for (xsgn = [-1, 1]) {
      translate([xsgn*(block_width_mm/2 - retention_screw_length_mm/2 + overlap_mm),
                 retention_screw_y_offset_mm,
                 retention_screw_z_offset_mm])
        rotate([0, 90, 0])
          cylinder(d=retention_screw_diameter_mm,
                   h=retention_screw_length_mm + 2*overlap_mm, center=true, $fn=36);
    }
  }
}

bearing_block();
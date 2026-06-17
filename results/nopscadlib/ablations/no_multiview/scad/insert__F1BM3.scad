// Parameters
insert_outer_diameter = 5.8; //[2.9:11.6:0.1]
insert_length = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter = 3; //[1.5:6:0.1]
internal_thread_pitch_mm = 0.5; //[0.25:1:0.05]
lead_in_chamfer_depth_mm = 0.4; //[0.2:0.8:0.05]
knurl_depth_mm = 0.2; //[0.1:0.4:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
tolerance_outer_diameter_mm = 0; //[-0.2:0.2:0.01]
tolerance_length_mm = 0; //[-0.3:0.3:0.01]
internal_thread_clearance_mm = 0.2; //[0.05:0.5:0.05]
bore_extra_depth_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
knurl_count = 18; //[8:40:1]
ridge_width_mm = 0.6; //[0.3:1.2:0.05]
ridge_height_fraction = 0.7; //[0.3:1:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Insert body with chamfer
      union() {
        // Main cylindrical body
        cylinder(
          r=(insert_outer_diameter + tolerance_outer_diameter_mm) / 2,
          h=insert_length + tolerance_length_mm,
          center=true
        );
        // Lead-in chamfer
        translate([0, 0, -(insert_length + tolerance_length_mm) / 2 + lead_in_chamfer_depth_mm / 2 - overlap_mm / 2])
          cylinder(
            r1=(insert_outer_diameter + tolerance_outer_diameter_mm) / 2,
            r2=(insert_outer_diameter + tolerance_outer_diameter_mm) / 2 - lead_in_chamfer_depth_mm,
            h=lead_in_chamfer_depth_mm,
            center=true
          );
      }
      // Internal thread bore
      cylinder(
        r=(screw_nominal_diameter + internal_thread_clearance_mm) / 2,
        h=(insert_length + tolerance_length_mm) + bore_extra_depth_mm,
        center=true
      );
    }
    // Knurling ridges
    union() {
      for (i = [0:knurl_count-1]) {
        rotate([0, 0, i * 360 / knurl_count])
          translate([(insert_outer_diameter + tolerance_outer_diameter_mm) / 2 + (knurl_depth_mm + overlap_mm) / 2 - overlap_mm, 0, 0])
            cube(
              [knurl_depth_mm + overlap_mm, ridge_width_mm, (insert_length + tolerance_length_mm) * ridge_height_fraction],
              center=true
            );
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
// Parameters
outer_diameter = 8.2; //[4.1:16.4:0.1]
length = 6.3; //[3.15:12.6:0.1]
screw_diameter = 4; //[2:8:0.1]
inner_thread_nominal = 4; //[3:6:1]
inner_minor_diameter = 3.3; //[1.65:6.6:0.05]
inner_major_diameter = 4; //[2:8:0.05]
lead_in_chamfer_length = 0.6; //[0.3:1.2:0.05]
lead_in_chamfer_angle_deg = 45; //[20:70:1]
knurl_depth = 0.3; //[0.15:0.6:0.05]
knurl_pitch = 1; //[0.5:2:0.05]
knurl_count = 12; //[6:24:1]
tolerance_outer_diameter = 0.1; //[0:0.3:0.01]
tolerance_length = 0.1; //[0:0.3:0.01]
overlap = 0.8; //[0.2:2:0.1]
ridge_width = 0.8; //[0.4:1.6:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Insert body with chamfer
        union() {
          // Main cylindrical body
          cylinder(
            h = length + tolerance_length,
            r = (outer_diameter + tolerance_outer_diameter) / 2,
            center = true
          );
          // Lead-in chamfer
          translate([0, 0, ((length + tolerance_length) / 2) - (lead_in_chamfer_length + overlap) / 2])
            cylinder(
              h = lead_in_chamfer_length + overlap,
              r1 = (outer_diameter + tolerance_outer_diameter) / 2,
              r2 = ((outer_diameter + tolerance_outer_diameter) / 2) - lead_in_chamfer_length,
              center = true
            );
        }
        // Knurl ridges
        for (i = [0:knurl_count-1]) {
          rotate([0, 0, i * 360 / knurl_count])
            translate([(outer_diameter + tolerance_outer_diameter) / 2 - (knurl_depth + overlap) / 2, 0, 0])
              cube(
                [knurl_depth + overlap, ridge_width, (length + tolerance_length) - 2 * lead_in_chamfer_length],
                center = true
              );
        }
      }
      // Internal thread or clearance bore
      cylinder(
        h = (length + tolerance_length) + 2 * overlap,
        r = inner_minor_diameter / 2,
        center = true
      );
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
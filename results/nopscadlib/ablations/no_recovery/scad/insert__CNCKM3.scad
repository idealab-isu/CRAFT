// Parameters
outer_diameter_mm = 3; //[1.5:6:0.05]
length_mm = 4.6; //[2.3:9.2:0.05]
screw_nominal_diameter_mm = 3; //[1.5:6:0.1]
internal_thread = 1; //[0:1:1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
pilot_bore_diameter_mm = 2.5; //[1.25:5:0.05]
clearance_bore_diameter_mm = 3.1; //[2.5:4:0.05]
chamfer_length_mm = 0.3; //[0:1:0.05]
chamfer_angle_deg = 45; //[15:75:1]
knurling = 0; //[0:1:1]
knurl_depth_mm = 0.15; //[0.05:0.3:0.01]
knurl_pitch_mm = 0.6; //[0.3:1.2:0.05]
tolerance_outer_diameter_mm = 0.1; //[0:0.3:0.01]
tolerance_length_mm = 0.1; //[0:0.3:0.01]
eps_mm = 0.5; //[0.2:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  // Calculate chamfer radius reduction
  chamfer_radius_reduction = chamfer_length_mm * tan(chamfer_angle_deg * PI / 180);

  // Main body with chamfers
  union() {
    // Main cylindrical body
    cylinder(
      h = length_mm + tolerance_length_mm,
      r = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
      center = true
    );

    // Top chamfer
    translate([0, 0, (length_mm + tolerance_length_mm) / 2 - (chamfer_length_mm + eps_mm) / 2])
      cylinder(
        h = chamfer_length_mm + eps_mm,
        r1 = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
        r2 = max(0, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_radius_reduction),
        center = true
      );

    // Bottom chamfer
    translate([0, 0, -(length_mm + tolerance_length_mm) / 2 + (chamfer_length_mm + eps_mm) / 2])
      rotate([180, 0, 0])
      cylinder(
        h = chamfer_length_mm + eps_mm,
        r1 = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
        r2 = max(0, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_radius_reduction),
        center = true
      );
  }

  // Internal bore (threaded or clearance)
  difference() {
    // Main body with chamfers
    union() {
      // Main cylindrical body
      cylinder(
        h = length_mm + tolerance_length_mm,
        r = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
        center = true
      );

      // Top chamfer
      translate([0, 0, (length_mm + tolerance_length_mm) / 2 - (chamfer_length_mm + eps_mm) / 2])
        cylinder(
          h = chamfer_length_mm + eps_mm,
          r1 = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
          r2 = max(0, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_radius_reduction),
          center = true
        );

      // Bottom chamfer
      translate([0, 0, -(length_mm + tolerance_length_mm) / 2 + (chamfer_length_mm + eps_mm) / 2])
        rotate([180, 0, 0])
        cylinder(
          h = chamfer_length_mm + eps_mm,
          r1 = (outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
          r2 = max(0, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_radius_reduction),
          center = true
        );
    }

    // Internal bore
    cylinder(
      h = (length_mm + tolerance_length_mm) + 2 * eps_mm,
      r = ((internal_thread * pilot_bore_diameter_mm) + ((1 - internal_thread) * clearance_bore_diameter_mm)) / 2,
      center = true
    );
  }
}

// Assembly
module assembly() {
  color("Brass") threaded_insert();
}

assembly();
// Parameters
outer_diameter = 4; //[2:8:0.1]
outer_diameter_tolerance = 0; //[-0.2:0.2:0.01]
length = 6.3; //[3.15:12.6:0.1]
length_tolerance = 0; //[-0.5:0.5:0.01]
screw_diameter = 4; //[2:8:0.1]
internal_thread_pitch = 0.7; //[0.35:1.4:0.05]
internal_minor_diameter_est = 3.3; //[2:6:0.05]
internal_bore_diameter = 3.3; //[2:6:0.05]
chamfer_length = 0.5; //[0.2:1.5:0.05]
chamfer_angle_deg = 45; //[20:70:1]
eps = 0.2; //[0.05:0.5:0.01]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Insert body
      cylinder(
        h = length + length_tolerance,
        r = (outer_diameter + outer_diameter_tolerance) / 2,
        center = true
      );
      
      // Internal thread bore
      translate([0, 0, 0])
        cylinder(
          h = (length + length_tolerance) + 2 * eps,
          r = internal_bore_diameter / 2,
          center = true
        );
      
      // Lead-in chamfer
      translate([0, 0, -(length + length_tolerance) / 2 + (chamfer_length + eps) / 2])
        cylinder(
          h = chamfer_length + eps,
          r1 = (outer_diameter + outer_diameter_tolerance) / 2,
          r2 = internal_bore_diameter / 2,
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
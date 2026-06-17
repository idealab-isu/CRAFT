// Parameters
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 7.1; //[3.55:14.2:0.1]
screw_diameter_mm = 5; //[2.5:10:0.1]
internal_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
center_bore_minor_diameter_mm = 4.2; //[2.1:8.4:0.05]
entry_chamfer_height_mm = 0.5; //[0.25:1:0.05]
entry_chamfer_angle_deg = 45; //[15:75:1]
bottom_chamfer_height_mm = 0.3; //[0.15:0.6:0.05]
bottom_chamfer_angle_deg = 30; //[15:60:1]
knurl_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
tolerance_outer_diameter_mm = 0; //[-0.2:0.2:0.01]
tolerance_length_mm = 0; //[-0.3:0.3:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]
knurl_rib_count = 8; //[4:16:1]
knurl_rib_width_mm = 0.6; //[0.3:1.2:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert Body
    difference() {
      union() {
        // Main cylindrical body
        cylinder(
          r=(outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
          h=length_mm + tolerance_length_mm,
          center=true
        );

        // Knurl ribs
        for (i = [0:knurl_rib_count-1]) {
          rotate([0, 0, i * 360 / knurl_rib_count])
          translate([
            (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - overlap_mm / 2 + (knurl_depth_mm + overlap_mm) / 2,
            0,
            0
          ])
          cube([
            knurl_depth_mm + overlap_mm,
            knurl_rib_width_mm,
            (length_mm + tolerance_length_mm) - entry_chamfer_height_mm - bottom_chamfer_height_mm
          ], center=true);
        }
      }

      // Internal thread bore
      cylinder(
        r=center_bore_minor_diameter_mm / 2,
        h=(length_mm + tolerance_length_mm) + 2 * overlap_mm,
        center=true
      );

      // Entry chamfer
      translate([0, 0, (length_mm + tolerance_length_mm) / 2 - entry_chamfer_height_mm / 2])
      rotate([180, 0, 0])
      cylinder(
        r1=(center_bore_minor_diameter_mm / 2) + entry_chamfer_height_mm,
        r2=center_bore_minor_diameter_mm / 2,
        h=entry_chamfer_height_mm + overlap_mm,
        center=true
      );

      // Bottom chamfer
      translate([0, 0, -(length_mm + tolerance_length_mm) / 2 + bottom_chamfer_height_mm / 2])
      cylinder(
        r1=(center_bore_minor_diameter_mm / 2) + bottom_chamfer_height_mm,
        r2=center_bore_minor_diameter_mm / 2,
        h=bottom_chamfer_height_mm + overlap_mm,
        center=true
      );
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
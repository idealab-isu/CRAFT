// Parameters
screw_nominal_diameter_mm = 2.5; //[1.25:5:0.05]
outer_diameter_mm = 5.8; //[2.9:11.6:0.05]
length_mm = 4.6; //[2.3:9.2:0.05]
tolerance_outer_diameter_mm = 0; //[-0.2:0.2:0.01]
tolerance_length_mm = 0; //[-0.2:0.2:0.01]
chamfer_mm = 0.3; //[0.1:0.8:0.05]
knurl_depth_mm = 0.35; //[0.15:0.8:0.05]
knurl_count = 24; //[12:48:1]
knurl_width_mm = 0.6; //[0.3:1.2:0.05]
knurl_overlap_mm = 0.8; //[0.3:1.5:0.05]
bore_diameter_mm = 2.1; //[1.6:2.6:0.05]
bore_clearance_mm = 0.1; //[0:0.3:0.01]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert body
    union() {
      cylinder(
        r=(outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
        h=length_mm + tolerance_length_mm,
        center=true
      );

      // Lead-in chamfer
      translate([0, 0, (length_mm + tolerance_length_mm) / 2 - chamfer_mm / 2])
        cylinder(
          r1=(outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
          r2=max((outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_mm, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 * 0.7),
          h=chamfer_mm,
          center=true
        );

      // Installation end chamfer
      translate([0, 0, -(length_mm + tolerance_length_mm) / 2 + chamfer_mm / 2])
        cylinder(
          r1=max((outer_diameter_mm + tolerance_outer_diameter_mm) / 2 - chamfer_mm, (outer_diameter_mm + tolerance_outer_diameter_mm) / 2 * 0.7),
          r2=(outer_diameter_mm + tolerance_outer_diameter_mm) / 2,
          h=chamfer_mm,
          center=true
        );

      // Knurl ribs
      for (i = [0:knurl_count-1]) {
        rotate([0, 0, i * 360 / knurl_count])
          translate([(outer_diameter_mm + tolerance_outer_diameter_mm) / 2 + (knurl_depth_mm + knurl_overlap_mm) / 2 - knurl_overlap_mm, 0, 0])
          cube(
            [knurl_depth_mm + knurl_overlap_mm, knurl_width_mm, length_mm + tolerance_length_mm - 2 * chamfer_mm],
            center=true
          );
      }
    }

    // Internal thread or clearance bore
    difference() {
      cylinder(
        r=(bore_diameter_mm + bore_clearance_mm) / 2,
        h=length_mm + tolerance_length_mm + 2 * eps_mm,
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
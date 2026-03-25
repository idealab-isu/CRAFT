// Parameters
screw_diameter = 8.0; //[4.0:16.0:0.1]
outer_diameter = 18.0; //[9.0:36.0:0.1]
length = 16.0; //[8.0:32.0:0.1]
thread_pitch_mm = 1.25; //[0.5:3.0:0.05]
bore_diameter_for_modeling = 6.8; //[5.0:8.0:0.05]
lead_in_chamfer_height = 1.0; //[0.5:2.0:0.05]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
installation_end_chamfer_height = 0.8; //[0.4:1.6:0.05]
knurl_depth = 0.6; //[0.3:1.2:0.05]
knurl_pitch = 1.2; //[0.6:2.4:0.05]
knurl_count = 24; //[8:64:1]
tolerance_outer_diameter = 0.0; //[-0.5:0.5:0.05]
tolerance_length = 0.0; //[-0.5:0.5:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
rib_width = 1.2; //[0.6:2.4:0.05]
rib_height_fraction = 0.7; //[0.4:1.0:0.05]

// Module for the heat-set insert
module insert() {
  color("Brass") {
    // Main body
    cylinder(
      r=(outer_diameter + tolerance_outer_diameter) / 2,
      h=length + tolerance_length,
      center=true
    );

    // Lead-in chamfer
    translate([0, 0, ((length + tolerance_length) / 2) - (lead_in_chamfer_height + overlap) / 2])
      cylinder(
        r1=(outer_diameter + tolerance_outer_diameter) / 2,
        r2=((outer_diameter + tolerance_outer_diameter) / 2) - lead_in_chamfer_height,
        h=lead_in_chamfer_height + overlap,
        center=true
      );

    // Installation end chamfer
    translate([0, 0, -((length + tolerance_length) / 2) + (installation_end_chamfer_height + overlap) / 2])
      rotate([180, 0, 0])
      cylinder(
        r1=(outer_diameter + tolerance_outer_diameter) / 2,
        r2=((outer_diameter + tolerance_outer_diameter) / 2) - installation_end_chamfer_height,
        h=installation_end_chamfer_height + overlap,
        center=true
      );

    // Ribs for knurling
    for (i = [0:knurl_count-1]) {
      rotate([0, 0, i * 360 / knurl_count])
      translate([((outer_diameter + tolerance_outer_diameter) / 2) - (knurl_depth + overlap) / 2, 0, 0])
      cube(
        [knurl_depth + overlap, rib_width, (length + tolerance_length) * rib_height_fraction],
        center=true
      );
    }
  }
}

// Module for the threaded insert
module threaded_insert() {
  difference() {
    insert();
    // Internal bore for threading
    cylinder(
      r=bore_diameter_for_modeling / 2,
      h=(length + tolerance_length) + 2 * overlap,
      center=true
    );
  }
}

// Assembly of the insert
module assembly() {
  threaded_insert();
}

assembly();
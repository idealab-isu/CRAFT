// Parameters
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 8; //[4:16:0.1]
screw_diameter_mm = 4; //[2:8:0.1]
inner_thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
tolerance_mm = 0.1; //[0.05:0.3:0.01]
chamfer_mm = 0.5; //[0.2:1.5:0.1]
knurl_depth_mm = 0.4; //[0.2:1:0.05]
knurl_pitch_mm = 1; //[0.5:2:0.1]
knurl_tooth_width_mm = 0.6; //[0.3:1.2:0.05]
knurl_count = 8; //[4:20:1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Insert body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

      // Internal thread or clearance bore
      translate([0, 0, 0])
        cylinder(r=(screw_diameter_mm + tolerance_mm)/2, h=length_mm + 2*overlap_mm, center=true);

      // Lead-in chamfers
      union() {
        translate([0, 0, length_mm/2 - chamfer_mm/2 + overlap_mm/2])
          cylinder(r1=(screw_diameter_mm + tolerance_mm)/2 + chamfer_mm, r2=(screw_diameter_mm + tolerance_mm)/2, h=chamfer_mm, center=true);
        translate([0, 0, -length_mm/2 + chamfer_mm/2 - overlap_mm/2])
          cylinder(r1=(screw_diameter_mm + tolerance_mm)/2, r2=(screw_diameter_mm + tolerance_mm)/2 + chamfer_mm, h=chamfer_mm, center=true);
      }

      // Knurl rings
      for (i = [0:knurl_count-1]) {
        translate([0, 0, -length_mm/2 + chamfer_mm + knurl_pitch_mm*i])
          scale([(outer_diameter_mm - 2*knurl_depth_mm)/outer_diameter_mm, (outer_diameter_mm - 2*knurl_depth_mm)/outer_diameter_mm, 1])
          cylinder(r=outer_diameter_mm/2, h=knurl_tooth_width_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
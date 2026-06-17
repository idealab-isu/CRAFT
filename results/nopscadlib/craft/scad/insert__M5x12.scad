// Parameters
outer_diameter_mm = 12.0; //[6.0:24.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.1]
screw_diameter_mm = 5.0; //[2.5:10.0:0.1]
internal_hole_diameter_mm = 5.0; //[4.0:6.5:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:1.5:0.05]
knurl_depth_mm = 0.3; //[0.1:0.8:0.05]
knurl_pitch_mm = 1.0; //[0.5:2.5:0.1]
knurl_groove_width_mm = 0.6; //[0.3:1.2:0.05]
knurl_count = 8; //[4:16:1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Insert body with chamfer
      difference() {
        // Main body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        // Lead-in chamfer
        translate([0, 0, length_mm/2 - (lead_in_chamfer_mm + overlap_mm)/2])
          cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - lead_in_chamfer_mm, h=lead_in_chamfer_mm + overlap_mm, center=true);
      }
      // Knurl grooves
      union() {
        for (i = [0:knurl_count-1]) {
          rotate([0, 0, i*360/knurl_count]) {
            for (j = [0:4]) {
              translate([outer_diameter_mm/2 - knurl_depth_mm + overlap_mm, 0, j*knurl_pitch_mm - (length_mm/2 - knurl_pitch_mm/2)]) {
                cube([2*knurl_depth_mm + 2*overlap_mm, outer_diameter_mm + 2*overlap_mm, knurl_groove_width_mm], center=true);
              }
            }
          }
        }
      }
    }
    // Internal thread bore
    translate([0, 0, 0])
      cylinder(r=internal_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
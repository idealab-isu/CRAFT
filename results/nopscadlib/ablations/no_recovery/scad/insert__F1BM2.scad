// Parameters
outer_diameter_mm = 4; //[2:8:0.1]
length_mm = 3.6; //[1.8:7.2:0.1]
screw_diameter_mm = 2; //[1:4:0.1]
internal_pilot_diameter_mm = 1.6; //[0.8:3.2:0.05]
internal_minor_diameter_mm = 1.6; //[0.8:3.2:0.05]
internal_major_diameter_mm = 2; //[1:4:0.05]
top_chamfer_depth_mm = 0.3; //[0.15:0.6:0.05]
bottom_chamfer_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_depth_mm = 0.2; //[0.1:0.4:0.05]
knurl_pitch_mm = 0.6; //[0.3:1.2:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
knurl_count = 20; //[8:40:1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Outer cylinder
        translate([0, 0, 0])
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

        // Knurl ribs
        for (i = [0:knurl_count-1]) {
          rotate([0, 0, i*360/knurl_count])
            translate([outer_diameter_mm/2 + (knurl_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
              cube([knurl_depth_mm + overlap_mm, knurl_pitch_mm/2, length_mm - 2*(top_chamfer_depth_mm + bottom_chamfer_depth_mm)/3], center=true);
        }
      }

      // Internal bore
      translate([0, 0, 0])
        cylinder(r=internal_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);

      // Top entry chamfer
      translate([0, 0, length_mm/2 - (top_chamfer_depth_mm + overlap_mm)/2])
        cylinder(r1=internal_major_diameter_mm/2, r2=0, h=top_chamfer_depth_mm + overlap_mm, center=true);

      // Bottom lead-in chamfer
      translate([0, 0, -length_mm/2 + (bottom_chamfer_depth_mm + overlap_mm)/2])
        cylinder(r1=internal_major_diameter_mm/2, r2=0, h=bottom_chamfer_depth_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
// Parameters
outer_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 2.5; //[1.2:5.0:0.1]
internal_hole_diameter_mm = 2.5; //[1.2:4.0:0.05]
internal_thread_pitch_mm = 0.45; //[0.2:1.0:0.01]
top_chamfer_height_mm = 0.4; //[0.2:1.0:0.05]
bottom_chamfer_height_mm = 0.4; //[0.2:1.0:0.05]
knurl_depth_mm = 0.25; //[0.1:0.6:0.01]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
knurl_count = 12; //[6:24:1]
knurl_groove_width_mm = 0.5; //[0.2:1.2:0.05]
knurl_band_height_mm = 3.2; //[1.6:6.4:0.1]
knurl_band_center_offset_mm = 0.0; //[-1.0:1.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      // Main body with chamfers
      union() {
        // Main cylindrical body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        
        // Top chamfer
        translate([0, 0, length_mm/2 - top_chamfer_height_mm/2])
          rotate([180, 0, 0])
          cylinder(r1=outer_diameter_mm/2, r2=0, h=top_chamfer_height_mm, center=true);
        
        // Bottom chamfer
        translate([0, 0, -length_mm/2 + bottom_chamfer_height_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=0, h=bottom_chamfer_height_mm, center=true);
      }
      
      // Internal clearance bore
      cylinder(r=internal_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Knurl grooves
      for (i = [0:knurl_count-1]) {
        rotate([0, 0, i*360/knurl_count])
          translate([outer_diameter_mm/2 - (knurl_depth_mm + overlap_mm)/2, 0, knurl_band_center_offset_mm])
          cube([knurl_depth_mm + overlap_mm, knurl_groove_width_mm, knurl_band_height_mm + 2*overlap_mm], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
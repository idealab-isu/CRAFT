// Parameters
outer_diameter_mm = 18; //[9:36:0.1]
length_mm = 16; //[8:32:0.1]
screw_nominal_diameter_mm = 8; //[4:16:0.1]
internal_pitch_mm = 1.25; //[0.5:2.5:0.05]
internal_minor_diameter_mm = 6.7; //[3.35:13.4:0.05]
internal_tap_drill_diameter_mm = 6.8; //[3.4:13.6:0.05]
end_chamfer_mm = 0.8; //[0.4:1.6:0.05]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
knurl_depth_mm = 0.5; //[0.25:1:0.05]
knurl_pitch_mm = 1; //[0.5:2:0.05]
knurl_ridge_width_mm = 0.6; //[0.3:1.2:0.05]
knurl_ridge_height_mm = 12; //[6:16:0.1]
knurl_band_offset_mm = 0; //[-2:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
bore_extra_length_mm = 2; //[1:4:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    // Insert body with chamfers
    difference() {
      // Main body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      
      // Internal bore
      translate([0, 0, 0])
        cylinder(r=internal_minor_diameter_mm/2, h=length_mm + bore_extra_length_mm, center=true);
      
      // Lead-in chamfers
      union() {
        translate([0, 0, length_mm/2 - end_chamfer_mm/2])
          cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=outer_diameter_mm/2 - end_chamfer_mm*tan(lead_in_chamfer_angle_deg), h=end_chamfer_mm + overlap_mm, center=true);
        translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
          cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=outer_diameter_mm/2 - end_chamfer_mm*tan(lead_in_chamfer_angle_deg), h=end_chamfer_mm + overlap_mm, center=true);
      }
    }
    
    // Knurl ridges
    union() {
      for (i = [0:15]) {
        rotate([0, 0, i*360/(floor((PI*outer_diameter_mm)/knurl_pitch_mm))])
          translate([outer_diameter_mm/2 + (knurl_depth_mm + overlap_mm)/2 - overlap_mm, 0, knurl_band_offset_mm])
            cube([knurl_depth_mm + overlap_mm, knurl_ridge_width_mm, knurl_ridge_height_mm], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
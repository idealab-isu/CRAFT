// Parameters
outer_diameter_mm = 4; //[2:8:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
screw_nominal_diameter_mm = 2.5; //[1.2:5:0.1]
internal_thread_pitch_mm = 0.45; //[0.2:0.9:0.01]
internal_minor_diameter_mm = 2.05; //[1.02:4.1:0.01]
internal_major_diameter_mm = 2.5; //[1.25:5:0.01]
internal_thread_length_mm = 4.2; //[2.1:8.4:0.1]
end_chamfer_mm = 0.3; //[0.15:0.6:0.05]
knurl_depth_mm = 0.25; //[0.1:0.5:0.01]
knurl_band_count = 3; //[1:8:1]
knurl_band_height_mm = 1; //[0.5:2:0.05]
center_bore_allowance_mm = 0.1; //[0:0.3:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]
knurl_tooth_count = 18; //[8:40:1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Insert body
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
        
        // Knurl bands
        for (i = [-1, 0, 1]) {
          translate([0, 0, i * (knurl_band_height_mm + overlap_mm)]) {
            union() {
              // Knurl band core
              cylinder(h=knurl_band_height_mm, r=outer_diameter_mm/2 + knurl_depth_mm, center=true);
              
              // Knurl teeth
              for (j = [0:knurl_tooth_count-1]) {
                rotate([0, 0, j * 360/knurl_tooth_count]) {
                  translate([(outer_diameter_mm/2 + knurl_depth_mm) - (knurl_depth_mm + overlap_mm)/2, 0, 0]) {
                    cube([knurl_depth_mm + overlap_mm, (2*3.141592653589793*(outer_diameter_mm/2 + knurl_depth_mm))/knurl_tooth_count, knurl_band_height_mm], center=true);
                  }
                }
              }
            }
          }
        }
      }
      
      // Lead-in chamfers
      translate([0, 0, length_mm/2 - end_chamfer_mm/2]) rotate([180, 0, 0]) 
        cylinder(h=end_chamfer_mm, r1=outer_diameter_mm/2, r2=0, center=true);
      translate([0, 0, -length_mm/2 + end_chamfer_mm/2]) 
        cylinder(h=end_chamfer_mm, r1=outer_diameter_mm/2, r2=0, center=true);
      
      // Internal thread or clearance bore
      cylinder(h=internal_thread_length_mm + 2*overlap_mm, r=(internal_minor_diameter_mm + center_bore_allowance_mm)/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
// Parameters
outer_diameter_mm = 12.0; //[6.0:24.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.1]
screw_diameter_mm = 5.0; //[2.5:10.0:0.1]
internal_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
internal_minor_diameter_mm = 4.2; //[2.1:8.4:0.05]
internal_major_diameter_mm = 5.0; //[2.5:10.0:0.05]
lead_in_chamfer_depth_mm = 0.6; //[0.3:1.2:0.05]
lead_in_chamfer_angle_deg = 45; //[15:75:1]
end_chamfer_depth_mm = 0.4; //[0.2:1.0:0.05]
end_chamfer_angle_deg = 30; //[15:75:1]
knurl_height_mm = 0.4; //[0.2:1.0:0.05]
knurl_count = 24; //[8:64:1]
knurl_rib_width_mm = 1.0; //[0.5:2.0:0.05]
knurl_overlap_mm = 0.8; //[0.5:2.0:0.05]
chamfer_clearance_mm = 0.2; //[0.1:0.6:0.05]
bore_clearance_mm = 0.1; //[0.0:0.3:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Insert body
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
        
        // Knurl ribs
        for (i = [0:knurl_count-1]) {
          rotate([0, 0, i*360/knurl_count])
          translate([outer_diameter_mm/2 + (knurl_height_mm + knurl_overlap_mm)/2 - knurl_overlap_mm, 0, 0])
          cube([knurl_height_mm + knurl_overlap_mm, knurl_rib_width_mm, length_mm], center=true);
        }
      }
      
      // Lead-in chamfer
      translate([0, 0, length_mm/2 - lead_in_chamfer_depth_mm/2])
      cylinder(h=lead_in_chamfer_depth_mm, r1=(outer_diameter_mm/2) + chamfer_clearance_mm, r2=(outer_diameter_mm/2) - lead_in_chamfer_depth_mm, center=true);
      
      // Installation-end chamfer
      translate([0, 0, -length_mm/2 + end_chamfer_depth_mm/2])
      cylinder(h=end_chamfer_depth_mm, r1=(outer_diameter_mm/2) + chamfer_clearance_mm, r2=(outer_diameter_mm/2) - end_chamfer_depth_mm, center=true);
      
      // Internal thread or clearance bore
      cylinder(h=length_mm + 2, r=(internal_minor_diameter_mm + bore_clearance_mm)/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
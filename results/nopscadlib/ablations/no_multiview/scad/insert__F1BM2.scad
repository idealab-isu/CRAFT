// Parameters
outer_diameter_mm = 4; //[2:8:0.1]
length_mm = 3.6; //[1.8:7.2:0.1]
screw_nominal_diameter_mm = 2; //[1:4:0.1]
bore_diameter_mm = 1.6; //[1:3.2:0.05]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
top_chamfer_depth_mm = 0.3; //[0.15:0.6:0.05]
bottom_chamfer_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_depth_mm = 0.2; //[0.1:0.4:0.05]
knurl_pitch_mm = 0.6; //[0.3:1.2:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
knurl_ring_thickness_mm = 0.25; //[0.15:0.6:0.05]
knurl_ring_count = 5; //[2:12:1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        
        // Top entry chamfer
        translate([0, 0, length_mm/2 - (top_chamfer_depth_mm + overlap_mm)/2 + overlap_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=bore_diameter_mm/2, h=top_chamfer_depth_mm + overlap_mm, center=true);
        
        // Bottom lead-in chamfer
        translate([0, 0, -length_mm/2 + (bottom_chamfer_depth_mm + overlap_mm)/2 - overlap_mm/2])
          cylinder(r1=bore_diameter_mm/2, r2=outer_diameter_mm/2, h=bottom_chamfer_depth_mm + overlap_mm, center=true);
        
        // External knurl/barbs
        for (i = [0:knurl_ring_count-1]) {
          translate([0, 0, -length_mm/2 + top_chamfer_depth_mm + knurl_pitch_mm*i])
            cylinder(r=outer_diameter_mm/2 + knurl_depth_mm, h=knurl_ring_thickness_mm, center=true);
        }
      }
      
      // Internal thread or clearance bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
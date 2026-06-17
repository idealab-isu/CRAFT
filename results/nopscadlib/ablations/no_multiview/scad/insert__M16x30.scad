// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 25; //[12.5:50:0.5]
screw_diameter_mm = 16; //[8:32:0.5]
internal_thread_pitch_mm = 2; //[1:4:0.25]
lead_in_chamfer_mm = 1; //[0.5:3:0.25]
knurl_depth_mm = 0.5; //[0.2:1.5:0.1]
knurl_pitch_mm = 1.5; //[0.8:3:0.1]
knurl_ring_thickness_mm = 0.8; //[0.4:2:0.1]
knurl_ring_count = 10; //[4:24:1]
bore_clearance_mm = 0.4; //[0.1:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        
        // Knurl rings
        for (i = [0:knurl_ring_count-1]) {
          translate([0, 0, -length_mm/2 + lead_in_chamfer_mm + knurl_pitch_mm*i])
            cylinder(r=outer_diameter_mm/2 + knurl_depth_mm, h=knurl_ring_thickness_mm, center=true);
        }
        
        // Lead-in chamfers
        translate([0, 0, length_mm/2 - lead_in_chamfer_mm - overlap_mm])
          rotate_extrude() polygon(points=[
            [0, 0],
            [outer_diameter_mm/2 + overlap_mm, 0],
            [outer_diameter_mm/2 + overlap_mm, lead_in_chamfer_mm + overlap_mm],
            [outer_diameter_mm/2 - lead_in_chamfer_mm, 0]
          ]);
        
        translate([0, 0, -length_mm/2 - overlap_mm])
          rotate_extrude() polygon(points=[
            [0, 0],
            [outer_diameter_mm/2 + overlap_mm, 0],
            [outer_diameter_mm/2 + overlap_mm, lead_in_chamfer_mm + overlap_mm],
            [outer_diameter_mm/2 - lead_in_chamfer_mm, 0]
          ]);
      }
      
      // Internal bore for M16 thread
      cylinder(r=(screw_diameter_mm + bore_clearance_mm)/2, h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
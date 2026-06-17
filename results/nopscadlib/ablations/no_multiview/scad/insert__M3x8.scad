// Parameters
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_mm = 6.0; //[3.0:12.0:0.1]
screw_nominal_diameter_mm = 3.0; //[2.0:6.0:0.1]
internal_thread_pitch_mm = 0.5; //[0.35:1.0:0.01]
pilot_hole_diameter_mm = 4.2; //[3.0:6.0:0.05]
knurl_depth_mm = 0.4; //[0.2:1.0:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
end_chamfer_mm = 0.5; //[0.2:1.5:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:1.5:0.05]
tolerance_mm = 0.1; //[0.0:0.3:0.01]
bore_through = 1; //[0:1:1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
knurl_ring_height_mm = 0.5; //[0.3:1.2:0.05]
knurl_ring_count = 5; //[2:12:1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
        
        // External knurl/barbs
        for (i = [0:knurl_ring_count-1]) {
          translate([0, 0, -length_mm/2 + lead_in_chamfer_mm + knurl_ring_height_mm/2 + i*knurl_pitch_mm])
            cylinder(h=knurl_ring_height_mm, r=outer_diameter_mm/2 + knurl_depth_mm, center=true);
        }
      }
      
      // Internal bore
      cylinder(h=length_mm + 2*overlap_mm, r=(pilot_hole_diameter_mm + tolerance_mm)/2, center=true);
      
      // Lead-in chamfer
      translate([0, 0, length_mm/2 - lead_in_chamfer_mm/2])
        cylinder(h=lead_in_chamfer_mm, r1=outer_diameter_mm/2, r2=0, center=true);
      
      // Installation end chamfer
      translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
        cylinder(h=end_chamfer_mm, r1=outer_diameter_mm/2, r2=0, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
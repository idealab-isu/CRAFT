// Parameters
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 7.1; //[3.55:14.2:0.1]
screw_nominal_diameter_mm = 5.0; //[2.5:10:0.1]
internal_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
internal_bore_diameter_mm = 4.2; //[3.2:5:0.05]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
lead_in_chamfer_depth_mm = 0.5; //[0.25:1:0.05]
outer_profile_depth_mm = 0.3; //[0.15:0.6:0.05]
outer_profile_pitch_mm = 0.8; //[0.4:1.6:0.05]
outer_profile_rings_count = 6; //[3:14:1]
outer_profile_ring_width_factor = 0.55; //[0.3:0.9:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    // Main body with knurl/barb profile
    union() {
      // Base cylinder
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      
      // Knurl/barb rings
      for (i = [0:outer_profile_rings_count-1]) {
        translate([0, 0, -length_mm/2 + outer_profile_pitch_mm*(i+0.5)])
          cylinder(h=outer_profile_pitch_mm*outer_profile_ring_width_factor, 
                   r=outer_diameter_mm/2 + outer_profile_depth_mm, center=true);
      }
    }
    
    // Internal bore and lead-in chamfer
    difference() {
      // Outer profile
      union() {
        // Base cylinder with knurl/barb profile
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
        
        // Knurl/barb rings
        for (i = [0:outer_profile_rings_count-1]) {
          translate([0, 0, -length_mm/2 + outer_profile_pitch_mm*(i+0.5)])
            cylinder(h=outer_profile_pitch_mm*outer_profile_ring_width_factor, 
                     r=outer_diameter_mm/2 + outer_profile_depth_mm, center=true);
        }
      }
      
      // Internal bore
      cylinder(h=length_mm + 2*overlap_mm, r=internal_bore_diameter_mm/2, center=true);
      
      // Lead-in chamfer
      translate([0, 0, length_mm/2 - (lead_in_chamfer_depth_mm + overlap_mm)/2])
        cylinder(h=lead_in_chamfer_depth_mm + overlap_mm, 
                 r1=outer_diameter_mm/2, r2=internal_bore_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
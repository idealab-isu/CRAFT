// Parameters
outer_diameter_mm = 8.2; //[4.1:16.4:0.1]
length_mm = 6.3; //[3.15:12.6:0.1]
screw_diameter_mm = 4; //[2:8:0.1]
internal_thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
internal_minor_diameter_mm = 3.3; //[1.65:6.6:0.05]
internal_tap_drill_mm = 3.3; //[1.65:6.6:0.05]
lead_in_chamfer_mm = 0.5; //[0.25:1:0.05]
end_chamfer_mm = 0.5; //[0.25:1:0.05]
knurl_depth_mm = 0.3; //[0.15:0.6:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
center_bore_through = 1; //[0:1:1]
eps_mm = 0.2; //[0.05:0.5:0.05]
knurl_ring_width_mm = 0.35; //[0.2:0.8:0.05]
knurl_ring_count = 6; //[3:14:1]
knurl_start_margin_mm = 0.9; //[0.4:1.8:0.05]

// Module for the threaded insert
module threaded_insert() {
  color([0.8, 0.6, 0.2]) { // Brass color
    difference() {
      union() {
        // Main body with chamfers
        union() {
          // Main cylindrical body
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
          
          // Lead-in chamfer
          translate([0, 0, length_mm/2 - lead_in_chamfer_mm/2])
            cylinder(r1=outer_diameter_mm/2, r2=0, h=lead_in_chamfer_mm, center=true);
          
          // Installation end chamfer
          translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
            cylinder(r1=outer_diameter_mm/2, r2=0, h=end_chamfer_mm, center=true);
        }
        
        // Knurling effect
        scale([(outer_diameter_mm - 2*knurl_depth_mm)/outer_diameter_mm, 
               (outer_diameter_mm - 2*knurl_depth_mm)/outer_diameter_mm, 1]) {
          difference() {
            cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
            for (i = [0:knurl_ring_count-1]) {
              translate([0, 0, -length_mm/2 + knurl_start_margin_mm + (i + 0.5)*((length_mm - 2*knurl_start_margin_mm)/knurl_ring_count)])
                cylinder(r=outer_diameter_mm/2, h=knurl_ring_width_mm, center=true);
            }
          }
        }
      }
      
      // Internal bore for M4 screw
      cylinder(r=internal_tap_drill_mm/2, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
// Parameters
outer_diameter = 25.0; //[12.5:50.0:0.1]
length = 18.5; //[9.25:37.0:0.1]
screw_diameter = 10.0; //[5.0:20.0:0.1]
internal_thread_depth = 18.5; //[9.25:37.0:0.1]
internal_bore_diameter = 8.5; //[6.0:11.0:0.1]
lead_in_chamfer_height = 1.0; //[0.5:2.0:0.1]
lead_in_chamfer_angle_deg = 45.0; //[15.0:60.0:1]
installation_end_chamfer_height = 1.0; //[0.5:2.0:0.1]
installation_end_chamfer_angle_deg = 30.0; //[15.0:60.0:1]
external_profile_depth = 0.6; //[0.3:1.2:0.05]
external_profile_pitch = 1.2; //[0.6:2.4:0.1]
ring_count = 10; //[4:20:1]
ring_width_factor = 0.55; //[0.3:0.9:0.05]
flange_height = 1.2; //[0.6:2.4:0.1]
flange_diameter = 27.0; //[25.0:54.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert Body
    difference() {
      union() {
        // Main Body
        translate([0, 0, 0])
          cylinder(h=length, r=outer_diameter/2, center=true, $fn=64);
        
        // Top Flange
        translate([0, 0, length/2 + flange_height/2 - overlap])
          cylinder(h=flange_height, r=flange_diameter/2, center=true, $fn=64);
        
        // External Rings
        for (i = [0:ring_count-1]) {
          translate([0, 0, -length/2 + external_profile_pitch*(i + 0.5)])
            cylinder(h=external_profile_pitch*ring_width_factor, r=outer_diameter/2 + external_profile_depth, center=true, $fn=64);
        }
      }
      
      // Internal Bore
      translate([0, 0, 0])
        cylinder(h=internal_thread_depth + 2*overlap, r=internal_bore_diameter/2, center=true, $fn=64);
      
      // Lead-in Chamfer
      translate([0, 0, length/2 - (lead_in_chamfer_height + overlap)/2])
        cylinder(h=lead_in_chamfer_height + overlap, r1=outer_diameter/2 + overlap, r2=outer_diameter/2 - lead_in_chamfer_height, center=true, $fn=64);
      
      // Installation End Chamfer
      translate([0, 0, -length/2 + (installation_end_chamfer_height + overlap)/2])
        cylinder(h=installation_end_chamfer_height + overlap, r1=outer_diameter/2 + overlap, r2=outer_diameter/2 - installation_end_chamfer_height, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();
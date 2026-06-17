// Parameters
thread_diameter_mm = 4.0; //[2.0:8.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 8.0; //[6.0:16.0:0.1]
head_height_mm = 4.0; //[2.0:8.0:0.1]
socket_hex_af_mm = 3.0; //[2.0:6.0:0.1]
socket_depth_mm = 2.5; //[1.5:5.0:0.1]
thread_pitch_mm = 0.7; //[0.4:1.25:0.05]
thread_length_mm = 10.0; //[5.0:20.0:0.5]
shank_diameter_mm = 4.0; //[2.0:8.0:0.1]
head_to_shank_chamfer_height_mm = 0.8; //[0.4:1.6:0.05]
head_to_shank_chamfer_radius_delta_mm = 1.0; //[0.5:2.0:0.05]
thread_runout_length_mm = 1.4; //[0.7:3.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 9.0; //[6.0:18.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.5:0.1]
washer_hole_diameter_mm = 4.5; //[4.1:6.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Cap Head
    translate([0, 0, head_height_mm/2])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);
    
    // Threaded Shaft
    translate([0, 0, -length_mm/2 + overlap_mm])
      cylinder(r=shank_diameter_mm/2, h=length_mm, center=true, $fn=64);
    
    // Head to Shank Chamfer
    translate([0, 0, overlap_mm + head_to_shank_chamfer_height_mm/2])
      cylinder(r1=head_diameter_mm/2, r2=shank_diameter_mm/2, h=head_to_shank_chamfer_height_mm, center=true, $fn=64);
    
    // Thread Runout
    translate([0, 0, -thread_runout_length_mm/2 + overlap_mm])
      cylinder(r=shank_diameter_mm/2, h=thread_runout_length_mm, center=true, $fn=64);
    
    // Hex Socket
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      difference() {
        cylinder(r=socket_hex_af_mm/(2*cos(30)), h=socket_depth_mm, center=true, $fn=6);
      }
  }
  
  if (washer_enabled) {
    color("Silver") {
      // Washer
      translate([0, 0, washer_thickness_mm/2])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
          translate([0, 0, 0])
            cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=64);
        }
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();
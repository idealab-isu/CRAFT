// Parameters
thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 10.0; //[5.0:20.0:0.5]
head_height_mm = 5.0; //[2.5:10.0:0.5]
hex_socket_af_mm = 4.0; //[2.0:8.0:0.1]
hex_socket_depth_mm = 3.0; //[1.5:6.0:0.1]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 10.0; //[5.0:20.0:0.5]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
fit_clearance_mm = 0.3; //[0.0:0.8:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// M5 Socket Head Cap Screw
module screw() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -length_mm/2])
      cylinder(r=thread_diameter_mm/2, h=length_mm, center=true, $fn=32);
    
    // Socket Head
    translate([0, 0, head_height_mm/2 - overlap_mm])
      difference() {
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=32);
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2])
          cylinder(r=hex_socket_af_mm/(2*cos(30)), h=hex_socket_depth_mm + overlap_mm*2, center=true, $fn=6);
      }
  }
}

// Washer
module washer() {
  color("Silver") {
    difference() {
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=32);
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        cylinder(r=thread_diameter_mm/2 + fit_clearance_mm, h=washer_thickness_mm + overlap_mm*4, center=true, $fn=32);
    }
  }
}

// Screw and Washer Assembly
module screw_and_washer() {
  union() {
    screw();
    scale([washer_enabled, washer_enabled, washer_enabled]) washer();
  }
}

// Final Assembly
module assembly() {
  screw_and_washer();
}

assembly();
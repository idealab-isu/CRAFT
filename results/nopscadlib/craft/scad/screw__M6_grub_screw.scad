// Parameters
thread_standard = 0; //[0:0:1]
thread_size = 6; //[6:6:1]
screw_style = 0; //[0:0:1]
head_type = 0; //[0:0:1]
drive_type = 0; //[0:0:1]
length_mm = 12; //[6:24:1]
tip_type = 0; //[0:0:1]
material = 0; //[0:0:1]
show_threads = 1; //[0:1:1]
major_diameter = 6; //[5:12:0.1]
minor_diameter = 5; //[4:10:0.1]
hex_socket_af = 3; //[2:6:0.1]
hex_socket_depth = 3; //[2:6:0.1]
tip_chamfer_height = 0.6; //[0.2:1.5:0.1]
overlap = 0.8; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Threaded Shaft
    cylinder(h=length_mm, r=major_diameter/2, center=true, $fn=64);
    
    // Hex Socket Drive
    difference() {
      cylinder(h=hex_socket_depth + overlap, r=hex_socket_af/(2*cos(30)), center=true, $fn=6);
      translate([0, 0, -(hex_socket_depth/2)]) 
        cylinder(h=hex_socket_depth + overlap, r=hex_socket_af/(2*cos(30)), center=true, $fn=6);
    }
    
    // Tip Profile
    translate([0, 0, -(length_mm/2) + (tip_chamfer_height/2)])
      cylinder(h=tip_chamfer_height + overlap, r1=major_diameter/2, r2=(major_diameter/2) - tip_chamfer_height, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();
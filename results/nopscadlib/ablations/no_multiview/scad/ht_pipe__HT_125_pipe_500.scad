// Parameters
length_mm = 500; //[250:1000:1]
ht125_outer_diameter = 125; //[62.5:250:0.5]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 2.0; //[1.0:6.0:0.1]
socket_od_extra = 6.0; //[2.0:15.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Module for the HT Pipe with detailed geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=ht125_outer_diameter/2, center=false);
      
      // Inner void of the pipe
      translate([0, 0, -overlap])
        cylinder(h=length_mm + overlap*2, r=ht125_outer_diameter/2 - wall_thickness, center=false);
    }
    
    // Socket at one end
    translate([0, 0, length_mm - socket_length]) {
      difference() {
        // Outer socket
        cylinder(h=socket_length, r=ht125_outer_diameter/2 + socket_od_extra/2, center=false);
        
        // Inner void of the socket
        translate([0, 0, -overlap])
          cylinder(h=socket_length + overlap*2, r=ht125_outer_diameter/2 - wall_thickness - overlap, center=false);
      }
    }
  }
}

// Assembly module
module assembly() {
  ht_pipe();
}

// Call the assembly
assembly();